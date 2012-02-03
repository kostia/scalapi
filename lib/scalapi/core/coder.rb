# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    # A combination of decoding and encoding.
    class Coder

      # Creates a new decoder/encoder combination
      # A decoder is a hash mapping content type strings (and nil for "default") to the
      # real decoder. The real decoder and encoder must be capable of receiving
      # #call(data_to_process) (simple way: a reference to a method with arity 1).
      def initialize(decoder, encoder)
        @decoder = decoder
        @encoder = encoder
      end

      def decode(obj, content_type = nil)
        decoder = @decoder[content_type]
        raise "No decoder available for response content type #{content_type}" unless decoder
        decoder.call(obj)
      end

      def encode(obj)
        @encoder.call(obj)
      end

    end
  end
end
