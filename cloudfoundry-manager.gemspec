# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudfoundry-manager/version'

Gem::Specification.new do |gem|
  gem.name          = "cloudfoundry-manager"
  gem.version       = Cloudfoundry::Manager::VERSION
  gem.authors       = ["Carlos Goncalves"]
  gem.email         = ["cgoncalves@av.it.pt"]
  gem.summary       = %q{Cloud Foundry Manager}
  gem.description   = %q{Bootstrap and manage your CloudFoundry cloud instances}
  gem.homepage      = "http://atnog.av.it.pt"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'cfoundry'
  gem.add_dependency 'net-ssh'
  gem.add_dependency 'net-sftp'
  gem.add_dependency 'nats'
  gem.add_dependency 'rest-client'
end
