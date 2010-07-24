require 'spec_helper'

describe Redmine do
  let(:redmine) { Redmine.new }
  describe "#config" do
    it "should load the config from config.yml" do
      redmine.config.should == {"username"=>"username", "project"=>"project_name", "host"=>"http://localhost:3000/", "password"=>"password"}
    end
  end

  describe "#issues_for_commit" do
    it "should call HttpParty using the config" do
    end
  end
end
