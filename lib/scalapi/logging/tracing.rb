# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Logging
    class Tracing
      def self.noproxy
        %w(
          singleton_method_added
          inspect
          object_id
          equal?
        )
      end

      def initialize(wrapped, methods = [])
        @wrapped = wrapped
        meta = class << self; self; end
        (wrapped.methods - Tracing.noproxy).each do |method|
          meta.class_eval do
            symbol = method.to_sym
            begin
              define_method(symbol) do |*args|
                if methods.include?(symbol)
                  call = symbol.to_s
                  call << "(#{args.inspect[1..-1]})" unless args.empty?
                  Logging.trace("Invoking #{call} for #{wrapped}")
                end
                wrapped.__send__(symbol, *args)
              end
            end
          end
        end
      end
    end

    def self.trace(text)
      puts "[trace] #{text}"
    end
  end
end
