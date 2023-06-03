# frozen_string_literal: true

require './lib/record_not_unique/version'

Gem::Specification.new do |s|
  s.name          = 'record_not_unique'
  s.version       = RecordNotUnique::VERSION
  s.summary       = 'Handle ActiveRecord::RecordNotUnique exceptions gracefully!'
  s.description   = 'Handle ActiveRecord::RecordNotUnique exceptions gracefully with customisable error messages'
  s.authors       = ['Ritikesh G']
  s.email         = 'ritikesh.ganpathraj@freshworks.com'
  s.files         = ['lib/record_not_unique.rb', 'LICENSE']
  s.require_paths = ['lib']
  s.homepage      = 'http://rubygems.org/gems/record_not_unique'
  s.license       = 'MIT'
  s.add_runtime_dependency 'activerecord', '>= 3.2'
  s.required_ruby_version = '>= 2.6.9'

  s.metadata['rubygems_mfa_required'] = 'true'
end
