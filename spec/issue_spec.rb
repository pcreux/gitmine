require 'spec_helper'

describe Gitmine::Issue do
  let(:issue) { Gitmine::Issue.new }
  [:id, :subject, :status].each do |a|
    it "should have an #{a}" do
      issue.should respond_to a
    end
  end

  describe "#config" do
    it "should load the config from config.yml" do
      issue.config.should == {"host"=>"http://localhost:3000", "api_key"=>"api_key"}
    end
  end

  describe "#url (protected)" do
    it "should build up URL based on the config" do
      issue.send(:url, '123').should == 'http://localhost:3000/issues/123.xml?key=api_key'
    end

  end


  describe "#get_for_commit" do
    it "should parse the commit message to find a commit_id and call #get" do
      commit_msg = 'A commit msg Issue #123'
      Gitmine::Issue.should_receive(:parse_for_issue_id).with(commit_msg)
      Gitmine::Issue.get_for_commit(commit_msg)
    end
  end

  describe "#get (class method)" do
    it "should build_via_issue_id" do
      issue = Gitmine::Issue.new
      Gitmine::Issue.should_receive(:new) { issue }
      issue.should_receive(:build_via_issue_id)
      Gitmine::Issue.get(123)
    end
  end

  describe "#build_via_issue_id" do
    before do
      @httparty = mock(:http_party_response, :parsed_response => {'issue' => { 'subject' => 'A subject', 'status' => {'name' => 'Completed'}}})
      issue.stub!(:get) { @httparty }
    end

    it "should get issue data and load attributes" do
      issue.should_receive(:build_via_issue_id).with(123) { @httparty }
      issue.build_via_issue_id(123)
    end

    it "should load attributes" do
      issue.build_via_issue_id(123)
      issue.id.should == 123
      issue.subject.should == 'A subject'
      issue.status.should == 'Completed'
    end
  end

  describe "#get (protected instance method)" do
    it "should create a new issue via HTTParty" do
      issue.stub!(:url) { 'the_url' }
      HTTParty.should_receive(:get).with('the_url')
      issue.send(:get, 123)
    end
  end

end
