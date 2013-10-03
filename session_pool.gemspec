# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aviator/session_pool/version'

Gem::Specification.new do |spec|
  spec.name          = "aviator_session_pool"
  spec.version       = Aviator::SessionPool::VERSION
  spec.authors       = ["Mark Maglana", "Alfonso Dillera"]
  spec.email         = ["mmaglana@gmail.com", "aj.dillera@gmail.com"]
  spec.description   = %q{ A library for managing multiple Aviator sessions }
  spec.summary       = %q{ A library for managing multiple Aviator sessions }
  spec.homepage      = "http://github.com/aviator/session_pool"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'aviator', '>= 0.0.6'
  spec.add_dependency 'redis', '>= 2.0.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rb-fsevent', '~> 0.9.0'
  spec.add_development_dependency 'guard', '~> 1.8.0'
  spec.add_development_dependency 'guard-rake', '~> 0.0.0'
  spec.add_development_dependency 'guard-minitest', '~> 0.5.0'
  spec.add_development_dependency 'ruby_gntp', '~> 0.3.0'
  spec.add_development_dependency 'pry', '~> 0.9.0'
  spec.add_development_dependency 'yard', '~> 0.8.0'
  spec.add_development_dependency 'redcarpet', '~> 2.3.0'
end
