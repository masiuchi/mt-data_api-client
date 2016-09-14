require 'simplecov'
require 'coveralls'
require 'codeclimate-test-reporter'
require 'webmock/rspec'

if ENV['CIRCLECI']
  WebMock.disable_net_connect!(allow: 'codeclimate.com')
  CodeClimate::TestReporter.start do
    add_filter '/spec/'
  end
else
  Coveralls.wear! if ENV['TRAVIS']
  SimpleCov.start do
    add_filter '/spec/'
  end
end
