# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    module Features
      module Listable
        def all
          communication.get.map do |attributes|
            new(attributes, :stale => false)
          end
        end
      end
    end
  end
end
