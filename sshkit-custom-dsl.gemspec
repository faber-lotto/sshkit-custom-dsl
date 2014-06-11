# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sshkit/custom/dsl/version'

Gem::Specification.new do |spec|
  spec.name          = 'sshkit-custom-dsl'
  spec.version       = SSHKit::Custom::DSL::VERSION
  spec.authors       = ['Dieter Späth']
  spec.email         = ['d.spaeth@faber.de']
  spec.summary       = %q(Exchanges original sshkit dsl against a custom dsl)
  spec.description   = %q(Exchanges original sshkit dsl against a custom dsl. This DSL does not change the scope of the blocks.)
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'sshkit', '~> 1.5.1'
  spec.add_dependency 'scoped_storage'
  spec.add_dependency 'rake'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'

  spec.add_development_dependency 'rspec', '3.0.0'
  # show nicely how many specs have to be run
  spec.add_development_dependency 'fuubar'
  # extended console
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-remote'
end
