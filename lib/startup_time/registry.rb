# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/slice' # XXX in core since 2.5
require 'set'
require 'yaml'

module StartupTime
  # StartupTime::Registry - an interface to the tests configured in
  # resources/tests.yaml
  class Registry
    # the path to the test configuration file
    TEST_DATA = File.join(__dir__, '../../resources/tests.yaml')

    # map each group (e.g. "jvm") to an array of its member IDs
    # (e.g. ["java", "kotlin", "scala"])
    GROUPS = Hash.new { |h, k| h[k] = [] }.with_indifferent_access

    # the top-level hash in tests.yaml. keys are test IDs (e.g. "ruby"); values
    # are test specs
    TESTS = YAML.safe_load(File.read(TEST_DATA)).with_indifferent_access

    # perform some basic sanity checks on the test specs and populate the group
    # -> tests map
    TESTS.each do |id, test|
      if test[:compile] && !test[:source]
        abort "invalid test spec (#{id}): compiled tests must define a source file"
      end

      test[:groups].each do |group|
        if TESTS[group]
          abort "invalid test spec (#{id}): group ID (#{group}) conflicts with test ID"
        end

        GROUPS[group] << id
      end
    end

    # a hash which maps test IDs (e.g. "scala") to their corresponding group
    # names (e.g. ["compiled", "jvm", "slow"])
    def self.ids_to_groups(format: :ascii)
      if format == :json
        TESTS.entries.each_with_object({}) do |(id, test), target|
          target[id] = test[:groups].sort
        end
      else # ASCII
        TESTS.entries.map { |id, test| [id, test[:groups].sort.join(', ')] }
      end
    end

    def initialize
      @omit = Set.new
      @only = Set.new
    end

    # add the specified test(s) to the set of disabled tests
    def omit(id)
      @omit.merge(ids_for(id))
    end

    # add the specified test(s) to the set of enabled tests
    def only(id)
      @only.merge(ids_for(id))
    end

    # the subset of candidate tests which satisfy the `only` and `omit` criteria
    def selected_tests
      only = !@only.empty? ? @only : TESTS.keys.to_set
      test_ids = (only - @omit).to_a
      TESTS.slice(*test_ids)
    end

    private

    # takes a test ID or group ID and resolves it into its corresponding test IDs.
    # if it's already a test ID, it's wrapped in an array; otherwise, an array
    # of test IDs belonging to the group is returned.
    def ids_for(id)
      if TESTS[id]
        [id]
      elsif GROUPS.key?(id)
        GROUPS[id]
      else
        abort "Can't resolve IDs for: #{id.inspect}"
      end
    end
  end
end
