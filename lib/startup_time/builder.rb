# frozen_string_literal: true

require 'rake'
require 'shellwords'
require_relative 'util'

module StartupTime
  # StartupTime::Builder - clean and prepare the build directory
  #
  # this class provides two methods which clean (i.e. remove) and prepare the build
  # directory. the latter is done by executing the following tasks:
  #
  # 1) copy source files from the source directory to the build directory
  # 2) compile all of the target files that need to be compiled from source files
  #
  # once these tasks are complete, everything required to run the benchmark tests
  # will be available in the build directory
  class Builder
    SRC_DIR = File.absolute_path('../../resources/src', __dir__)

    include Rake::DSL
    include Util # for `which`
    include Services.mixin %i[options selected_tests]

    def initialize
      @verbosity = options.verbosity
      @build_dir = options.build_dir

      Rake.verbose(@verbosity != :quiet)
    end

    # remove the build directory and its contents
    def clean!
      rm_rf @build_dir
    end

    # ensure the build directory is in a fit state to run the tests i.e. copy
    # source files and compile target files
    def build!
      verbose(@verbosity == :verbose) do
        mkdir_p(@build_dir) unless Dir.exist?(@build_dir)
        cd @build_dir
      end

      register_tasks

      Rake::Task[:build].invoke
    end

    private

    # a wrapper for Rake's +FileUtils#sh+ method (which wraps +Kernel#spawn+)
    # which allows the command's environment to be included in the final options
    # hash rather than cramming it in as the first argument i.e.:
    #
    # before:
    #
    #   sh FOO_VERBOSE: "0", "foo -c hello.foo -o hello", out: File::NULL
    #
    # after:
    #
    #   shell "foo -c hello.foo -o hello", env: { FOO_VERBOSE: "0" }, out: File::NULL
    #
    def shell(args, **options)
      args = Array(args) # args is a string or array
      env = options.delete(:env)
      args.unshift(env) if env
      sh(*args, options)
    end

    # a conditional version of Rake's `file` task which compiles a source file to
    # a target file via the block provided. if the compiler isn't installed, the
    # task is skipped.
    #
    # returns a truthy value (the target filename) if the task is created, or nil
    # otherwise
    def compile_if(id, **options)
      tests = options[:force] ? Registry::TESTS : selected_tests

      # look up the test's spec among the remaining tests which haven't been
      # excluded by --omit or --only
      return unless (test = tests[id])

      # the compiler name (e.g. "crystal") is usually the same as the ID for
      # the test (e.g. "crystal"), but can be supplied explicitly in the test
      # spec e.g. { id: "java-native", compiler: "native-image" }
      compiler = test[:compiler] || id

      return unless (compiler_path = which(compiler))

      # the source filename must be supplied
      source = test.fetch(:source)

      # infer the target if not specified
      unless (target = test[:target])
        command = Array(test[:command])

        if command.length == 1
          target = command.first
        elsif source.match?(/^[A-Z]/) # JVM language
          target = source.pathmap('%n.class')
        else # native executable
          target = '%s.out' % source
        end
      end

      # update the test spec's compiler field to point to the compiler's
      # absolute path (which may be mocked)
      test = test.merge(compiler: compiler_path)

      # pass the test object as the block's second argument. Rake passes an
      # instance of +Rake::TaskArguments+, a Hash-like object which provides
      # access to the command-line arguments for a Rake task e.g. { name:
      # "world" } for `rake greet[world]`. since we're not relying on Rake's
      # limited option-handling support, we have no use for that here, so we
      # simply replace it with the test data.
      wrapper = ->(task, _) { yield(task, test) }

      # declare the prerequisites for the target file.
      # compiler_path: recompile if the compiler has been
      # updated since the target was last built
      file(target => [source, compiler_path], &wrapper)

      # add the target file to the build task
      task :build => target

      target
    end

    # register the prerequisites of the :build task. creates file tasks which:
    #
    # a) keep the build directory sources in sync with the source directory
    # b) rebuild target files if their source files are modified
    # c) rebuild target files if their compilers are updated
    def register_tasks
      copy_source_files
      compile_target_files
    end

    # ensure each file in the source directory is mirrored to the build
    # directory, and add each task which ensures this as a prerequisite
    # of the master task (:build)
    def copy_source_files
      Dir["#{SRC_DIR}/*.*"].each do |path|
        filename = File.basename(path)

        source = file(filename => path) do
          verbose(@verbosity == :verbose) { cp path, filename }
        end

        task build: source
      end
    end

    # run a shell command (string) by substituting the compiler path, source
    # file, and target file into the supplied template and executing the
    # resulting command with the test's (optional) environment hash
    def run(template, task, test)
      replacements = {
        compiler: Shellwords.escape(test[:compiler]),
        source: Shellwords.escape(task.source),
        target: Shellwords.escape(task.name),
      }

      command = template % replacements
      shell(command, env: test[:env])
    end

    # make sure the target files (e.g. native executables and JVM .class files)
    # are built if their compilers are installed
    def compile_target_files
      # handle the tests which have compile templates by turning them into
      # blocks which substitute the compiler, source file and target file into
      # the corresponding placeholders in the template and then execute the
      # command via `shell`
      selected_tests.each do |id, selected|
        if (command = selected[:compile])
          block = ->(task, test) { run(command, task, test) }
          compile_if(id, &block)
        end
      end

      # native-image compiles .class files to native binaries. it differs from
      # the other tasks because it depends on a target file rather than a
      # source file i.e. it depends on the target of the javac task
      java_native = compile_if('java-native', connect: false) do |t, test|
        # XXX native-image doesn't provide a way to silence its output, so
        # send it to /dev/null
        shell [test[:compiler], "-H:Name=#{t.name}", '--no-server', '-O1', t.source.ext], {
          out: File::NULL
        }
      end

      if java_native
        javac = compile_if(:javac, force: true) do |task, test|
          run('%{compiler} -d . %{source}', task, test)
        end

        if javac
          task :build => java_native
        end
      else
        compile_if :javac do |task, test|
          run('%{compiler} -d . %{source}', task, test)
        end
      end

      compile_if 'kotlinc-native' do |t, test|
        # XXX kotlinc-native doesn't provide a way to silence
        # its debug messages, so file them under /dev/null
        shell %W[#{test[:compiler]} -opt -o #{t.name} #{t.source}], out: File::NULL

        # XXX work around a kotlinc-native "feature"
        # https://github.com/JetBrains/kotlin-native/issues/967
        exe = "#{t.name}.kexe" # XXX or .exe, or...
        verbose(@verbosity == :verbose) { mv exe, t.name } if File.exist?(exe)
      end
    end
  end
end
