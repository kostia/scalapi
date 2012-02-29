# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  class Credential < Core::Model

    features :listable, :creatable
    features :top_level => "credentials"

    def delete
      communication.delete
    end

  end
end
