# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'startup_time/version'

Gem::Specification.new do |spec|
  spec.name     = 'startup-time'
  spec.version  = StartupTime::VERSION
  spec.author   = 'chocolateboy'
  spec.email    = 'chocolate@cpan.org'
  spec.summary  = 'A command-line tool to measure the startup times of programs in various languages'
  spec.homepage = 'https://github.com/chocolateboy/startup-time'
  spec.license  = 'Artistic-2.0'

  spec.description = <<~'EOS'.strip.gsub(/\s+/, ' ')
    A benchmarking tool which measures how long it takes to execute
    "Hello, world!" programs in various languages.
  EOS

  spec.files = `git ls-files -z -- *.md bin lib resources ':!:resources/rubocop'`.split("\0")
  spec.executables = Dir['bin/*'].map { |path| File.basename(path) }

  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => 'https://github.com/chocolateboy/startup-time/issues',
    'changelog_uri'     => 'https://github.com/chocolateboy/startup-time/blob/master/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/chocolateboy/startup-time',
  }

  spec.add_runtime_dependency 'activesupport', '~> 5.2'
  spec.add_runtime_dependency 'bundler', '~> 2'
  spec.add_runtime_dependency 'cli-pasta', '~> 2.0'
  spec.add_runtime_dependency 'env_paths', '~> 1.0'
  spec.add_runtime_dependency 'komenda', '~> 0.1.8'

  # we need at least 11.2, which includes "spawn options for sh"
  spec.add_runtime_dependency 'rake', '~> 13'

  spec.add_runtime_dependency 'tty-table', '~> 0.11'
  spec.add_runtime_dependency 'tty-which', '~> 0.4'
  spec.add_runtime_dependency 'values', '~> 1.8'
  spec.add_runtime_dependency 'wireless', '~> 0.0.2'

  spec.add_development_dependency 'rubocop', '~> 0.80'
end
