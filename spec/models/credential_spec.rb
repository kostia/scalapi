# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require File.expand_path("../../spec_helper.rb", __FILE__)

module Scalapi
  describe Credential, "#delete" do
    before do
      intercept_scalapi_calls
    end

    let(:credential) {
      Credential.new("cred_under_test")
    }

    it "should send a DELETE request do '/credentials/<credential_id>'" do
      intercepted_calls["credentials/cred_under_test"].should_receive(:delete)
      credential.delete
    end
  end
end
