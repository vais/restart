# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'restart/version'

Gem::Specification.new do |spec|
  spec.name          = "restart"
  spec.version       = Restart::VERSION
  spec.authors       = ["Vais Salikhov"]
  spec.email         = ["vsalikhov@gmail.com"]
  spec.summary       = %q{Runs your shell command, then re-runs it any time filesystem change is detected.}
  spec.description   = %q{For example, "restart ruby test.rb" will run "ruby test.rb", then re-run it after test.rb file changes (or any other files change in current working directory or any subdirectories under it).}
  spec.homepage      = "http://github.com/vais/restart"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "listen", "~> 2.7.9"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
