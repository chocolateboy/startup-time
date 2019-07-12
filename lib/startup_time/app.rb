# frozen_string_literal: true

require 'benchmark'
require 'komenda'
require 'shellwords' # for Array#shelljoin
require 'tty/table'

# FIXME we only need bundler/setup here, but it appears to create an incomplete
# Bundler object which (sometimes) confuses Komenda as well as causing a
# Gem::LoadError (for unicode-display_width)
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
    include Services.mixin %i[builder ids_to_groups selected_tests]

    def initialize(args = ARGV)
      @options = Options.new(args)
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
      if @verbosity == :verbose
        # used by StartupTime::App#time to dump the command line
        require 'shellwords'
      end

      case @options.action
      when :clean
        builder.clean!
      when :help
        puts @options.usage
      when :show_ids
        puts render_ids_to_groups
      when :version
        puts VERSION
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

      selected_tests.entries.shuffle.each do |id, test|
        time(id, test)
      end

      sorted = @times.sort_by { |result| result[:time] }

      if @options.format == :json
        require 'json'
        puts sorted.to_json
      elsif !sorted.empty?
        pairs = sorted.map { |result| [result[:name], '%.02f' % result[:time]] }
        table = TTY::Table.new(['Test', 'Time (ms)'], pairs)
        puts unless @verbosity == :quiet
        puts table.render(:basic, alignments: %i[left right])
      end
    end

    # an ASCII table representation of the mapping from test IDs (e.g. "scala")
    # to group IDs (e.g. "compiled, jvm, slow")
    def render_ids_to_groups
      table = TTY::Table.new(%w[Test Groups], ids_to_groups)
      table.render
    end

    # takes a test ID and a test spec and measures how long it takes to execute
    # the test if either:
    #
    #   - its interpreter exists
    #   - it's a compiled executable (i.e. its compiler exists)
    #
    # otherwise, skip the test
    def time(id, test)
      args = Array(test[:command])

      if args.size == 1 # native executable
        compiler = test[:compiler] || id
        cmd = File.absolute_path(args.first)
        return unless File.exist?(cmd)
      else # interpreter + source
        compiler = args.first
        cmd = which(compiler)
        return unless cmd
      end

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
      command = [cmd, *args]

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
        @options.rounds.times do
          times << Benchmark.realtime do
            system([cmd, argv0], *args, out: File::NULL)
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
