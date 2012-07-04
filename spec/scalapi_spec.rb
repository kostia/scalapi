# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require File.expand_path("../spec_helper.rb", __FILE__)

module Scalapi
  describe ".configure {|config| ...}" do
    it "takes a (scalarium server url)" do
      expect {
        Scalapi.configure do |config|
          config.url = "url"
        end
      }.to change {
        Configuration.configuration.url
      }.to "url"
    end

    it "takes a (scalarium api authentication) token" do
      expect {
        Scalapi.configure do |config|
          config.token = "token"
        end
      }.to change {
        Configuration.configuration.token rescue nil
      }.to "token"
    end
  end
end

module Scalapi
  describe ".scalarium" do
    before do
      Scalapi.configure do |config|
        config.token = "token"
      end
    end

    it "returns the scalarium resource (for the current configuration)" do
      Scalapi.scalarium.should be_equal Scalapi.scalarium
    end

    it "returns a scalarium resource based on the current configuration" do
      Scalapi.configure do |config|
        config.url = "http://the/url"
      end
      scalarium_instance = Scalapi.scalarium
      scalarium_instance.should be_instance_of(Scalarium)
      scalarium_instance.communication.resource.url.should == "http://the/url"
      scalarium_instance.communication.resource.headers.should be_include('X-Scalarium-Token')
      scalarium_instance.communication.resource.headers['X-Scalarium-Token'].should == "token"
    end

    context "when using the default resource" do
      it "includes the the required request format headers" do
        scalarium_instance = Scalapi.scalarium
        scalarium_instance.communication.resource.headers.should be_include('Accept')
        scalarium_instance.communication.resource.headers['Accept'].should ==
            'application/vnd.scalarium-v1+json'
        scalarium_instance.communication.resource.headers.should be_include('Content-Type')
        scalarium_instance.communication.resource.headers['Content-Type'].should ==
            'application/json'
      end

    end

    context "when the configuration is changed" do
      before do
        # precondition: Scalapi.scalarium returns identical instances
        # (or tests need to verify differently)
        Scalapi.scalarium.object_id.should == Scalapi.scalarium.object_id
      end

      it "represents the current configuration" do
        expect {
          Scalapi.configure do |config|
            config.url = "http://different/url"
          end
        }.to change {
          Scalapi.scalarium.communication.resource.url
        }.to("http://different/url")
      end

      it "does not affect any previously returned scalarium instance" do
        before = Scalapi.scalarium
        expect {
          Scalapi.configure do |config|
            config.url = "changed"
            config.token = "changed"
          end
        }.to_not change {
          [
            before.communication.resource,
            before.communication.resource.url,
            before.communication.resource.headers,
          ]
        }
      end
    end
  end
end
