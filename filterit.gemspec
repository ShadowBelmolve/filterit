# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'filterit/version'

Gem::Specification.new do |gem|
  gem.name          = "filterit"
  gem.version       = FilterIt::VERSION
  gem.authors       = ["Renan Tomal Fernandes"]
  gem.email         = %w(renan@kauamanga.com.br)
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w(lib)

  gem.add_development_dependency 'rspec', '~> 2.11'
  gem.add_development_dependency 'rake'


  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rb-inotify', '~> 0.8.8'
end
