require './lib/record_not_unique/version'

Gem::Specification.new do |s|
  s.name          = %q{record_not_unique}
  s.version       = RecordNotUnique::VERSION
  s.date          = Time.now.utc.strftime("%Y-%m-%d")
  s.summary       = %q{Local Memoization Pattern!}
  s.description   = %q{Local Memoization Pattern to store complex and repeated computations in memory until the next hour/day/week}
  s.authors       = ["Ritikesh G"]
  s.email         = %q{ritikesh.ganpathraj@freshworks.com}
  s.files         = ["lib/record_not_unique.rb"]
  s.require_paths = ["lib"]
  s.homepage      = %q{http://rubygems.org/gems/record_not_unique}
  s.license       = %q{MIT}
  s.add_runtime_dependency 'activerecord', ">= 3.2", "< 4"
  s.add_development_dependency 'minitest', '~> 5.0'
end