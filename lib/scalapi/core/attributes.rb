# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    #
    # Simple container to handle properties
    #
    class Attributes

      attr_reader :attributes

      def initialize(attributes = nil)
        @attributes =
            if attributes
              attributes.inject({}) do |memo, (key, value)|
                memo[key.to_s] = value
                memo
              end
            else
              {}
            end
      end

      def [](name)
        attributes[name.to_s]
      end

    end
  end
end

