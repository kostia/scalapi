require "rubygems"
require 'jeweler'

Jeweler::Tasks.new do |s|
  s.name = "scalapi"
  s.description = "Library for communication with the Scalarium REST API."
  s.summary = "Library for communication with the Scalarium REST API. See README for details."
  s.authors = ["Infopark AG"]
  s.email = "info@infopark.de"
  s.homepage = "http://github.com/infopark/scalapi"
  s.files = FileList["[A-Z]*", "{lib,spec}/**/*"]
  s.test_files = FileList["{spec}/**/*"]
  s.add_runtime_dependency("rest-client", ">= 1.6")
  # s.add_runtime_dependency("json", "~> 1")
  s.add_development_dependency("rspec")
  s.extra_rdoc_files = ['README.rdoc']
end
# require 'bundler/gem_tasks'
# require 'rubygems/package_task'

Dir['tasks/**/*.rake'].each { |t| load t }