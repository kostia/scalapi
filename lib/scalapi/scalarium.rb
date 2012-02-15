# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  class Scalarium < Core::Base

    module Applications

      def applications
        nested_applications.all
      end

      def find_application(id)
        nested_applications.find(id)
      end

      def create_application(attributes)
        raise "create_application is available only as a cloud instance method"
      end

      def nested_applications
        nested("applications", :class => Application)
      end

      protected :nested_applications

    end

    module Clouds

      def clouds
        nested_clouds.all
      end

      def find_cloud(id)
        nested_clouds.find(id)
      end

      def delete_cloud(id)
        nested_clouds.build(id).delete
      end

      def create_cloud(attributes)
        nested_clouds.create(attributes)
      end

      def nested_clouds
        nested("clouds", :class => Cloud)
      end

      protected :nested_clouds

    end

    module Volumes

      def volumes
        nested_volumes.all
      end

      def find_volume(id)
        nested_volumes.find(id)
      end

      def delete_volume(id)
        nested_volumes.build(id).delete
      end

      def nested_volumes
        nested("volumes", :class => Volume)
      end

      protected :nested_volumes

    end

    include Applications
    include Clouds
    include Volumes

  end
end
