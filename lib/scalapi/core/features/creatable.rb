# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    module Features
      module Creatable
        def create(attributes = nil)
          new(communication.post(attributes), :stale => false)
        end
      end
    end
  end
end

