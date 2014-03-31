# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serf/client/version'

Gem::Specification.new do |spec|
  spec.name          = "serf-client"
  spec.version       = Serf::Client::VERSION
  spec.authors       = ["Jacob Evans"]
  spec.email         = ["jacob@dekz.net"]
  spec.summary       = %q{Serf Client}
  spec.description   = %q{Implementation of Serf RPC}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "msgpack"
  spec.add_dependency "celluloid"
  spec.add_dependency "celluloid-io"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
