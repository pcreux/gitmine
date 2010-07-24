require 'spec_helper'

describe Gitmine do
  let(:gitmine) { Gitmine.new }

  let(:commit_1) do
    mock(
      :message => "Commit 1 #1234",
      :committer => "Sam",
      :committed_date => Time.now
    )
  end

  before do
    Grit::Repo.stub!(:new) { 
      mock(Grit::Repo, :commits => [commit_1])
    }
  end
     
  describe "#commits" do
    it "should return the last 10 commit messages" do
      gitmine.commits.should == [commit_1]
    end
  end

  describe "#initialize" do
    context "when not a git repo" do
      it "should raise an exception"
    end

    context "when git repo" do
      it "should not raise any exception"
    end
  end
end
