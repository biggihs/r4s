# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'r4s/version'
require 'json'

Gem::Specification.new do |gem|
  gem.name          = "r4s"
  gem.version       = R4s::VERSION
  gem.authors       = ["Birgir Hrafn Sigurðsson"]
  gem.email         = ["biggihs@gmail.com"]
  gem.description   = %q{R4S is a gem that simplifies sending server side events (SSE) to multiple browsers in Rails 4. It is supposed to simulate broadcasting to all the browsers that are connected to it.}
  gem.summary       = %q{Wrapper for Rails 4 streaming}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
