# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'bundler/setup'

NO_TEST = %w[slow slow-compile].join(',')
GEMSPEC = Gem::Specification.load('startup-time.gemspec')

# an alternative to bundler's :install task which installs the dependencies, builds
# the documentation, and honors --user-install
desc 'Install %s and its dependencies into the system gems' % GEMSPEC.name
task :install_with_dependencies => %i[build] do
  Bundler.with_clean_env do
    sh 'gem install pkg/%s.gem' % GEMSPEC.full_name
  end
end

desc 'Check the codebase for style violations'
task :lint do
  sh 'rubocop --display-cop-names --config resources/rubocop/rubocop.yml'
end

desc 'Perform a quick test run of the command'
task :test => %i[build lint] do
  sh 'startup-time --version'
  sh 'startup-time --clean'
  sh "startup-time --omit #{NO_TEST} --verbose"
end

# run the test before release
task :release => :test

task :default => :test
