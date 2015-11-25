# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sidekiq/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Mike Kim']
  gem.email         = ['mykoweb@gmail.com']
  gem.description   = gem.summary = ''
  gem.homepage      = 'https://github.com/mykoweb/sidekiq-hol'
  gem.license       = 'MIT'

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'sidekiq-hol'
  gem.require_paths = ['lib']
  gem.version       = Sidekiq::Hol::VERSION

  gem.add_dependency             'sidekiq'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-byebug'
end
