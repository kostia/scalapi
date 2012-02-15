# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require "bundler"
Bundler.setup
require File.expand_path("../../lib/scalapi", __FILE__)
require File.expand_path("../../lib/scalapi-test", __FILE__)
require 'rspec'
require 'json'


Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.color = true
  config.before(:each) do
    ::Test::Scalapi.unconfigure
  end
end
