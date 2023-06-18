# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'activerecord', '>= 5.0.0'

group :development, :test do
  if ENV['ACTIVE_RECORD_VERSION'] && Gem::Version.new(ENV['ACTIVE_RECORD_VERSION']) < Gem::Version.new('6.0.0')
    gem 'mysql2', '~> 0.4.10'
  else
    gem 'mysql2', '~> 0.5.2'
  end
  gem 'rspec'
  gem 'rubocop'
  gem 'rubocop-rspec'
end
