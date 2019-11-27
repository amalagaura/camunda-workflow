require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage 100
end
