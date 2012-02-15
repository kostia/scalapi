# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    module Features
      module TopLevel
        def communication
          super || Scalapi.scalarium.communication[@top_level]
        end
      end
    end
  end
end

