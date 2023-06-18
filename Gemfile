# frozen_string_literal: true

active_record_version = ENV.fetch('ACTIVE_RECORD_VERSION', nil)

source 'https://rubygems.org'

gemspec

gem 'activerecord', active_record_version || '>= 5.0.0'

group :development, :test do
  if active_record_version && Gem::Version.new(active_record_version) < Gem::Version.new('6.0.0')
    gem 'mysql2', '~> 0.4.10'
  else
    gem 'mysql2', '~> 0.5.2'
  end
  gem 'rspec'
  gem 'rubocop'
  gem 'rubocop-rspec'
end
