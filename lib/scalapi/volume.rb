# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  class Volume < Core::Model

    features :listable, :creatable
    features :toplevel => "volumes"

    def snapshots
      nested("snapshots", :class => Snapshot).all
    end

    def create_snapshot(*attributes)
      nested("snapshots", :class => Snapshot).create(*attributes)
    end

  end
end
