require 'simplecov'
require 'coveralls'
require 'codeclimate-test-reporter'
require 'codecov'
require 'webmock/rspec'

if ENV['CIRCLECI']
  WebMock.disable_net_connect!(allow: 'codeclimate.com')
  CodeClimate::TestReporter.start do
    add_filter '/spec/'
  end
else
  Coveralls.wear! if ENV['TRAVIS'] && ENV['TRAVIS_RUBY_VERSION'] == '2.1.10'
  SimpleCov.start do
    add_filter '/spec/'
  end
  if ENV['TRAVIS'] && ENV['TRAVIS_RUBY_VERSION'] == '2.2.0'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  end
end
