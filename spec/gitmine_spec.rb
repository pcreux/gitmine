require 'spec_helper'

describe Gitmine do
  before do
    File.stub!(:read) { "ref: refs/heads/wip" }
  end

  let(:gitmine) { Gitmine.new }

  let(:commit_1) do
    mock(
      :message => "Commit 1 #1234",
      :committer => "Sam",
      :committed_date => Time.now
    )
  end

  let(:repo) do
    mock(Grit::Repo, :commits => [commit_1])
  end

  before do
    Grit::Repo.stub!(:new) { repo }
  end
     
  describe "#commits" do
    it "should return Gitmine commits" do
      gitmine.commits.first.should be_a Gitmine::Commit
    end
    it "should return commits for the current branch" do
      repo.should_receive(:commits).with('wip')
      gitmine.commits
    end
  end

  describe "#initialize" do
    let(:grit_repo) { mock(:checkout => true)}
    before do
      Grit::Repo.stub!(:new) { grit_repo }
    end

    it "should check out to the current branch" do
      Grit::Repo.should_receive(:new).with(ENV['PWD']) { grit_repo }
      Gitmine.new
    end
  end
end
