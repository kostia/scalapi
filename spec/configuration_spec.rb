# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require File.expand_path("../spec_helper.rb", __FILE__)

module Scalapi
  describe Configuration do
    describe ".configuration (default configuration)" do
      it "should be" do
        Configuration.configuration.should be
      end

      it "has the url #{url = "https://manage.scalarium.com/api"}" do
        Configuration.configuration.url.should == url
      end

      it "has no token" do
        Configuration.configuration.token(false).should be_nil
      end

      it "raises an error when accessing no token" do
        expect {
          Configuration.configuration.token
        }.to raise_error("Scalarium token has not been configured")
      end
    end

    context "when extending another configuration" do
      context "e.g. by configuring a higher request timeout" do
        let(:configuration_with_higher_request_timeout) {
          Configuration.new(Configuration.configuration).tap do |c|
            c.token = "unused"
            c.url = Test::Scalapi.url
            c.resource_builder = lambda {|url, options|
              require 'restclient'
              ::RestClient::Resource.new(url, options.merge(:timeout => 60))
            }
          end
        }

        let(:extended_resource) {
          configuration_with_higher_request_timeout.resource
        }

        it "returns a resource with the higher request timeout" do
          extended_resource.timeout.should == 60
        end

        it "has been provided the configured resource options" do
          extended_resource.headers['X-Scalarium-Token'].should == "unused"
        end
      end
    end
  end
end
