# frozen_string_literal: true

require 'bundler/gem_tasks'

NO_TEST = %w[no-test slow slow-compile].tap do |groups|
  groups << 'no-ci' if ENV['CI'] == 'true'
end.join(',')

desc 'Check the codebase for style violations'
task :rubocop do
  sh 'rubocop --display-cop-names --config resources/rubocop/rubocop.yml'
end

desc 'run the command'
task :test => %i[build rubocop] do
  sh 'startup-time --version'
  sh "startup-time --omit #{NO_TEST} --verbose"
end

task :release => :test
task :default => :test
