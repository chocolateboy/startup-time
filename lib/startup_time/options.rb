# frozen_string_literal: true

require 'env_paths'
require 'optparse'
require 'values'

module StartupTime
  # StartupTime::Options - a struct-like interface to the app options set or
  # overridden on the command line
  class Options
    BUILD_DIR = EnvPaths.get('startup-time', suffix: false).cache
    DEFAULT_DURATION = 10
    MINIMUM_DURATION = 2
    MINIMUM_ROUNDS = 2

    Spec = Value.new(:type, :value)

    attr_reader :action, :build_dir, :format, :rounds, :verbosity

    include Services.mixin %i[registry]

    def initialize(args)
      @action = :benchmark
      @build_dir = BUILD_DIR
      @duration = DEFAULT_DURATION
      @format = :default
      @parser = nil
      @rounds = nil
      @spec = nil
      @verbosity = :default

      parse! args
    end

    def spec
      @spec ||= if @rounds
        Spec.with(type: :count, value: @rounds)
      else
        Spec.with(type: :duration, value: @duration)
      end
    end

    # the usage message (string) generated by the option parser for this tool
    def usage
      @parser.to_s
    end

    private

    # process the command-line options and assign values to the corresponding
    # instance variables
    def parse!(args)
      @parser = OptionParser.new do |opts|
        opts.on(
          '-c',
          '--count',
          '--rounds INTEGER',
          Integer,
          "The number of times to run each program (minimum: #{MINIMUM_ROUNDS})"
        ) do |value|
          # XXX with ruby 2.4 (clamp) and 2.6 (start..):
          # @rounds = value.clamp(MINIMUM_ROUNDS..)
          @rounds = [MINIMUM_ROUNDS, value].max
        end

        opts.on(
          '--clean',
          'Remove the build directory and exit',
          '(targets will be recompiled on the next run)'
        ) do
          @action = :clean
        end

        opts.on(
          '-d',
          '--dir PATH',
          String,
          'Specify the build directory',
          "(default: #{BUILD_DIR})"
        ) do |value|
          @build_dir = value
        end

        opts.on(
          '-h',
          '--help',
          'Show this help message and exit'
        ) do
          @action = :help
        end

        opts.on(
          '-H',
          '--help-only',
          '--help-omit',
          'Show the IDs and groups that can be passed to --only and --omit'
        ) do
          @action = :show_ids
        end

        opts.on(
          '-j',
          '--json',
          'Output the results in JSON format (implies --quiet)'
        ) do
          @format = :json
          @verbosity = :quiet
        end

        opts.on(
          '-o',
          '--only LIST',
          Array, # comma-separated strings
          'Only run the specified tests (comma-separated list of IDs/groups)'
        ) do |values|
          values.each { |value| registry.only(value.strip) }
        end

        opts.on(
          '-O',
          '--omit LIST',
          Array, # comma-separated strings
          "Don't run the specified tests (comma-separated list of IDs/groups)"
        ) do |values|
          values.each { |value| registry.omit(value.strip) }
        end

        opts.on(
          '-q',
          '--quiet',
          'Suppress all inessential output'
        ) do
          @verbosity = :quiet
        end

        opts.on(
          '-t',
          '--time INTEGER',
          Integer,
          'Specify the minimum number of seconds to run the test suite for',
          "(minimum: #{MINIMUM_DURATION}, default: #{DEFAULT_DURATION})"
        ) do |value|
          # XXX with ruby 2.4 (clamp) and 2.6 (start..):
          # @duration = value.clamp(MINIMUM_DURATION..)
          @duration = [MINIMUM_DURATION, value].max
        end

        opts.on(
          '-v',
          '--verbose',
          'Enable verbose logging'
        ) do
          @verbosity = :verbose
        end

        opts.on(
          '-V',
          '--version',
          'Display the version and exit'
        ) do
          @action = :version
        end
      end

      @parser.parse!(args)
    end
  end
end
