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
  end
end
