# frozen_string_literal: true

require 'rake'

module StartupTime
  # add some missing methods/aliases to Rake tasks
  # TODO move to a gem (or PR)
  module Refinements
    refine Rake::FileTask do
      alias_method :target, :name
    end

    refine Rake::Task do
      alias_method :append, :enhance

      def prepend(deps = nil, &block)
        prerequisites.replace(Array(deps) | prerequisites) if deps
        actions.unshift(block) if block_given?
        self
      end
    end
  end
end
