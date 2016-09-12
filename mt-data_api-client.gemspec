# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mt/data_api/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'mt-data_api-client'
  spec.version       = MT::DataAPI::Client::VERSION
  spec.authors       = ['Masahiro Iuchi']
  spec.email         = ['masahiro.iuchi@gmail.com']

  spec.summary       = 'Movable Type Data API client for Ruby.'
  spec.description   = 'Movable Type Data API client for Ruby.'
  spec.homepage      = 'https://github.com/masiuchi/mt-data_api-client'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/})
  end
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'activesupport', '>= 4.2.7.1'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'rake', '~> 11.2'
  spec.add_development_dependency 'reek', '~> 4.4'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rubocop', '~> 0.42'
  spec.add_development_dependency 'webmock', '~> 2.1'
end
