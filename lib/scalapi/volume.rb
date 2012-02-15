# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  class Volume < Core::Model

    features :listable, :creatable
    features :top_level => "volumes"

    def snapshots
      nested("snapshots", :class => Snapshot).all
    end

    def create_snapshot(*attributes)
      nested("snapshots", :class => Snapshot).create(*attributes)
    end

    def delete
      communication.delete
    end

  end
end
