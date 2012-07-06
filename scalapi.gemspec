# -*- encoding: utf-8 -*-
require File.expand_path("../lib/scalapi/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "scalapi"
  s.version     = Scalapi::VERSION
  s.authors     = ["Infopark AG"]
  s.email       = ["info@infopark.de"]
  s.homepage    = "https://github.com/infopark/scalapi"
  s.summary     = "Library for communication with the Scalarium REST API. See README for details."
  s.description = "Library for communication with the Scalarium REST API."

  s.files       = Dir["[A-Z]*"] + Dir["{lib,spec,tasks}/**/*"]
  s.test_files  = Dir["spec/**/*"]
  s.executables   = []
  s.require_paths = ["lib"]

  s.license = 'MIT'                         # see MIT-LICENSE

  s.extra_rdoc_files = ['README.rdoc']

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "json"       # provides an engine for multi_json
  s.add_runtime_dependency "multi_json"
  s.add_runtime_dependency "rest-client"    # you could theoretically use a different client,
                                            # but you'll have to provide it's API then
end
