require 'simplecov'
require 'coveralls'
require 'codeclimate-test-reporter'
require 'webmock/rspec'

if ENV['TRAVIS']
  WebMock.disable_net_connect!(allow: 'codeclimate.com')
  Coveralls.wear!
  CodeClimate::TestReporter.start do
    add_filter '/spec/'
  end
else
  SimpleCov.start do
    add_filter '/spec/'
  end
end
