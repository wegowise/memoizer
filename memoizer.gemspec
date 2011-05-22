# -*- encoding: utf-8 -*-
require 'rubygems' unless defined? Gem
require File.dirname(__FILE__) + "/lib/memoizer/version"

Gem::Specification.new do |s|
  s.name        = "memoizer"
  s.version     = Memoizer::VERSION
  s.authors     = ["Barun Singh"]
  s.email       = "bsingh@wegowise.com"
  s.homepage    = "http://github.com/wegowise/memoizer"
  s.summary = "Memoizes (caches the results of) your methods"
  s.description =  "Memoizer caches the results of your method calls, works well with methods that accept arguments or return nil. It's a simpler and more expicit alternative to ActiveSupport::Memoizable"
  s.required_rubygems_version = ">= 1.3.6"
  s.files = Dir.glob(%w[{lib,spec}/**/*.rb [A-Z]*.{txt,rdoc,md} *.gemspec]) + %w{Rakefile}
  s.extra_rdoc_files = ["README.md", "LICENSE.txt"]
  s.license = 'MIT'
end
