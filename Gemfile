# frozen_string_literal: true

ruby_version = Gem::Version.new(RUBY_VERSION)

source 'https://rubygems.org'

gemspec

if ruby_version >= Gem::Version.new('3.0.0')
  # Gems for ActiveRecord 6.1.0 and higher
  gem 'activerecord', '>= 7.0.0'
  gem 'mysql2', '~> 0.5.3'
elsif ruby_version >= Gem::Version.new('2.7.0')
  # Gems for ActiveRecord 6.0.0 to 6.0.7
  gem 'activerecord', '>= 6.0.0', '< 6.1.0'
  gem 'mysql2', '~> 0.5.3'
else
  # Gems for ActiveRecord 5.0.0 to 5.2.7
  gem 'activerecord', '>= 5.0.0', '< 6.0.0'
  gem 'mysql2', '~> 0.4.10'
end

gem 'rspec'
gem 'rubocop'
gem 'rubocop-rspec'
