# frozen_string_literal: true

source 'https://rubygems.org'

unless ENV['CI']
  group :development do
    gem 'rubocop', '~> 0.90'
  end
end

# pull in runtime and test dependencies from the gemspec
gemspec development_group: :test
