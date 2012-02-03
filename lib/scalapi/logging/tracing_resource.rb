# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Logging
    class TracingResource < Tracing
      def initialize(wrapped, methods)
        super
        meta = class << self; self; end
        sub_resource_creator = method(:[])
        meta.class_eval do
          define_method(:[]) do |*args|
            TracingResource.new(sub_resource_creator.call(*args), methods)
          end
        end
      end
    end
  end
end
