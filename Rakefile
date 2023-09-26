# frozen_string_literal: true

require 'rake/testtask'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--pattern spec/**/*_spec.rb --warnings'
end

RuboCop::RakeTask.new

task default: %i[spec rubocop]
