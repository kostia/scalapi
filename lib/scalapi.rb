# encoding: utf-8
#
# Copyright (c) Infopark AG
#

require File.expand_path("../scalapi/version", __FILE__)

module Scalapi
  # The convenience "top level" scalarium resource handle using the default
  # configuration Scalapi::Configuration.configuration
  def self.scalarium
    @scalarium ||= bind(Configuration.configuration)
  end

  # Returns a new "top level" scalarium resource handle using the specified
  # configuration
  def self.bind(configuration)
    Scalarium.new(nil, :communication => configuration.communication)
  end

  # Configures the scalapi default configuration.
  # Resets the convenience scalarium handle.
  def self.configure(&block)
    Configuration.configuration.configure(&block)
    @scalarium = nil
  end

  # :nodoc:
  def self.setup_autoload(mod, mod_source)
    dir = File.expand_path(".", mod_source)[0..-4]
    pattern = "#{dir}/*.rb"
    Dir.glob(pattern).each do |file|
      next if file =~ %r(scalapi/version.rb$)
      const = "#{file[dir.length..-1]}"[0..-4].gsub(%r{[_/](.)}) {$1.upcase}
      mod.autoload const.to_sym, file
    end
  end

  setup_autoload(self, __FILE__)
end
