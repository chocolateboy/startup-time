# frozen_string_literal: true

require 'benchmark'
require 'json'
require 'komenda'
require 'shellwords' # for Array#shelljoin
require 'tty/table'

# FIXME we only need bundler/setup here (for Bundler.with_clean_env), but it appears
# to create an incomplete Bundler object which (sometimes) confuses Komenda as well
# as causing a Gem::LoadError (for unicode-display_width)
#
# require 'bundler/setup'
require 'bundler'

module StartupTime
  # StartupTime::App - the entry point for the app.
  # selects an action based on the command-line options and runs it.
  class App
    EXPECTED_OUTPUT = /\AHello, world!\r?\n\z/

    include FileUtils # for `sh`
    include Util # for `which`
    include Services.mixin %i[builder selected_tests]

    def initialize(args = ARGV)
      @options = Options.new(args)
      @json = @options.format == :json
      @verbosity = @options.verbosity
      @times = []

      # provide/publish the Options instance we've just created so it's
      # available to other components
      Services.once(:options) { @options }
    end

    # run the command corresponding to the command-line options:
    # either an auxiliary command (e.g. clean the build directory
    # or print a help message) or the default command, which runs
    # the selected benchmark-tests
    def run
      case @options.action
      when :clean
        builder.clean!
      when :help
        puts @options.usage
      when :version
        puts VERSION
      when :show_ids
        render_ids_to_groups
      else
        benchmark
      end
    end

    private

    # run the selected benchmark tests:
    #
    # 1) ensure everything in the build directory is up to date
    # 2) run the tests in random order and time each one
    # 3) sort the results from the fastest to the slowest
    # 4) display the results in the specified format (default: ASCII table)
    def benchmark
      builder.build!

      # run a test if:
      #
      #   - its interpreter exists
      #   - it's a compiled executable (i.e. its compiler exists)
      #
      # otherwise, skip it
      runnable_tests = selected_tests.each_with_object([]) do |(id, test), tests|
        args = Array(test[:command])

        if args.length == 1 # native executable
          compiler = test[:compiler] || id
          path = File.absolute_path(args.first)
          next unless File.exist?(path)
        else # interpreter + source
          compiler = args.first
          path = which(compiler)
          next unless path
        end

        tests << {
          id: id,
          test: test,
          args: args,
          compiler: compiler,
          path: path,
        }
      end

      if runnable_tests.empty?
        puts '[]' if @json
        return
      end

      spec = @options.spec

      if spec.type == :duration
        spec = spec.with(value: spec.value.to_f / runnable_tests.length)
      end

      runnable_tests.shuffle.each do |config|
        config[:spec] = spec
        time(config)
      end

      sorted = @times.sort_by { |result| result[:time] }

      if @json
        puts sorted.to_json
      else
        pairs = sorted.map { |result| [result[:name], '%.02f' % result[:time]] }
        table = TTY::Table.new(['Test', 'Time (ms)'], pairs)
        puts unless @verbosity == :quiet
        puts table.render(:basic, alignments: %i[left right])
      end
    end

    # print a JSON or ASCII-table representation of the mapping from test IDs
    # (e.g. "scala") to group IDs (e.g. ["compiled", "jvm", "slow"])
    def render_ids_to_groups
      if @json
        puts Registry.ids_to_groups(format: :json).to_json
      else
        table = TTY::Table.new(%w[Test Groups], Registry.ids_to_groups)
        puts table.render
      end
    end

    # takes a test configuration and measures how long it takes to execute the
    # test
    def time(id:, test:, args:, compiler:, path:, spec:)
      # dump the compiler/interpreter's version if running in verbose mode
      if @verbosity == :verbose
        puts
        puts "test: #{id}"

        # false (don't print the program's version); otherwise, a command
        # (template string) to execute to dump the version
        version = test[:version]

        unless version == false
          version ||= '%{compiler} --version'

          # the compiler may have been uninstalled since the target was
          # built, so make sure it still exists
          if (compiler_path = which(compiler))
            version_command = version % { compiler: compiler_path }
            sh version_command
          end
        end
      end

      argv0 = args.shift
      command = [path, *args]

      unless @verbosity == :quiet
        if @verbosity == :verbose
          puts "command: #{command.shelljoin}"
        else
          print '.'
        end
      end

      # make sure the command produces the expected output
      result = Komenda.run(command)
      output = result.output

      if result.error?
        abort "error running #{id} (#{result.status}): #{output}"
      end

      unless output.match?(EXPECTED_OUTPUT)
        abort "invalid output for #{id}: #{output.inspect}"
      end

      times = []

      # the bundler environment slows down ruby and breaks truffle-ruby,
      # so make sure it's disabled for the benchmark
      Bundler.with_clean_env do
        if spec.type == :duration # how long to run the tests for
          duration = spec.value
          elapsed = 0
          start = Time.now

          loop do
            time = Benchmark.realtime do
              system([path, argv0], *args, out: File::NULL)
            end

            elapsed = Time.now - start
            times << time

            break if elapsed >= duration
          end
        else # how many times to run the tests
          spec.value.times do
            times << Benchmark.realtime do
              system([path, argv0], *args, out: File::NULL)
            end
          end
        end
      end

      @times << {
        id: id,
        name: test[:name],
        time: (times.min * 1000).truncate(2)
      }
    end
  end
end
