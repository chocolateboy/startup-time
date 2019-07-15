# frozen_string_literal: true

require 'wireless'

module StartupTime
  # shared dependencies required by multiple components
  Services = Wireless.new do
    # the component responsible for managing the build directory
    once(:builder) { Builder.new }

    # an interface to the tests configured in resources/tests.yaml
    once(:registry) { Registry.new }

    # the tests which remain after the --only and --omit filters have been
    # applied
    once(:selected_tests) { |wl| wl[:registry].selected_tests }
  end
end
