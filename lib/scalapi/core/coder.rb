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

      def decode(obj, content_type_header = nil)
        content_type, charset = extract_content_type_and_charset(content_type_header)
        # TODO: be charset aware (at least: "utf-8")
        decoder = @decoder[content_type]
        raise "No decoder available for response content type #{content_type}" unless decoder
        decoder.call(obj)
      end

      def encode(obj)
        @encoder.call(obj)
      end

      def extract_content_type_and_charset(media_type)
        if media_type.to_s != ""
          content_type, *options = media_type.split(/\s*;\s*/)
          kv = options.inject({}) do |memo, opt_as_string|
            k, v = opt_as_string.split(/\s*=\s*/, 2)
            memo[k] = v
            memo
          end
          [content_type, kv['charset']]
        end
      end
    end
  end
end
