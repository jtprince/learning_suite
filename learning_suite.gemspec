# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'learning_suite/version'

Gem::Specification.new do |spec|
  spec.name          = "learning_suite"
  spec.version       = LearningSuite::VERSION
  spec.authors       = ["John T. Prince"]
  spec.email         = ["jtprince@gmail.com"]
  spec.description   = %q{manipulates gradesheets and iclicker things for learning suite}
  spec.summary       = %q{Manipulate BYU Learning Suite material}
  spec.homepage      = "http://byu.edu"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
