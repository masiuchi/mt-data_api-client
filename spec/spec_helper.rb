require 'simplecov'
require 'coveralls'

Coveralls.wear! if ENV['TRAVIS']

SimpleCov.start do
  add_filter '/spec/'
end
