# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'mysql2'
  gem 'rspec'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :test do
  active_record_version = ENV.fetch('ACTIVE_RECORD_VERSION', '>= 5.2')
  gem 'activerecord', active_record_version
end
