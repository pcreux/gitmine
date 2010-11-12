require 'spec_helper'

describe Gitmine::Commit do
  let(:grit_commit) { Grit::Commit.create(nil, {:message => "Commit message"}) }
  let(:commit) { Gitmine::Commit.new(grit_commit) }
  let(:issue)  { Gitmine::Issue.new }

  describe "#new" do
    it "should take a grit_commit object and store it" do
      commit.grit_commit.should == grit_commit
    end
  end

  it "should delegate methods to the grit_commit object" do
    commit.message.should == grit_commit.message
  end

  it "should delegate #id to the grit_commit object" do
    commit.id.should == grit_commit.id
  end

  it "should respond_to :issue" do
    commit.should respond_to :issue
  end

  it "should return issue via #Issue.get_for_commit" do
    Gitmine::Issue.should_receive(:get_for_commit).with("Commit message") { issue }
    commit.issue.should == issue
  end

  it "should memoize issue" do
    Gitmine::Issue.should_receive(:get_for_commit).with("Commit message") { issue }.once
    2.times do
      commit.issue.should == issue
    end
  end
end
