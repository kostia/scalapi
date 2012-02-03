# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    # Provides binding resource access (urls + marshalling) to the including
    # class' instances (or to the class, if extended)
    module Resource

      def communication=(communication)
        @communication = communication
      end

      def communication
        @communication
      end

    end
  end
end
