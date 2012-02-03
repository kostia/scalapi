# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    # The combination of a resource (url and requests) and marshalling
    #
    # It automatically decodes and encodes data send and received.
    #
    class Communication

      attr_reader :resource, :coder, :root

      def initialize(resource, coder, root = nil)
        @resource = resource
        @coder = coder
        @root = root || self
      end

      # Returns a copy of this communication for the given sub-path.
      def [](path)
        other_resource =
            case path
            when %r(^/)
              root.resource[path[1..-1]]
            when %r(\./)
              # cut off one level of "up" (relative URI is weird: . == parent, .. == grandparent)
              path = (URI.parse(resource.url) + path.sub(%r(^\.\./), "")).
                  to_s[root.resource.url.length+1..-1]
              root.resource[path]
            else
              resource[path]
            end
        Communication.new(other_resource, coder, root)
      end

      def encode(data)
        coder.encode(data) unless data.nil?
      end

      def decode(data)
        return data if data.nil? || data.empty?
        content_type = data.headers[:content_type] rescue nil
        coder.decode(data, content_type)
      end

      def get(*args)
        decode(resource.get(*args))
      end

      def post(data = nil)
        decode(resource.post(encode(data)))
      end

      def put(data)
        decode(resource.put(encode(data)))
      end

      def delete
        resource.delete
      end

    end
  end
end
