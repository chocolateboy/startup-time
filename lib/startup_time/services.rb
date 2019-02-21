# frozen_string_literal: true

require 'wireless'

module StartupTime
  # shared dependencies required by multiple components
  Services = Wireless.new do
    # the component responsible for managing the build directory
    once(:builder) { Builder.new }

    # a hash which maps test IDs (e.g. "scala") to group names
    # (e.g. "compiled, jvm, slow")
    once(:ids_to_groups) { Registry.ids_to_groups }

    # an interface to the tests configured in resources/tests.yaml
    once(:registry) { Registry.new }

    # the tests which remain after the --only and --omit filters have been
    # applied
    once(:selected_tests) { |wl| wl[:registry].selected_tests }
  end
end
