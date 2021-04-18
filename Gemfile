# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'rake', '~> 13.0'

group :development do
  gem 'pry', '~> 0.10'

  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
end

group :test do
  gem 'rspec', '~> 3.5'
  gem 'rspec_junit_formatter', '~> 0.3'

  gem 'rubocop', '~> 0.90.0'
  gem 'rubocop-rspec', '~> 1.43.2'

  gem 'webmock', '~> 3.0'

  gem 'timecop'
end

gemspec
