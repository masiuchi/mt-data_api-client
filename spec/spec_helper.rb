require 'simplecov'
require 'coveralls'

if ENV['TRAVIS']
  Coveralls.wear!
else
  SimpleCov.start do
    add_filter '/spec/'
  end
end
