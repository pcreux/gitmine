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

  describe ".branch" do
    let(:issue) do
      mock(Gitmine::Issue,
       :subject => 'Ticket title',
       :add_note => nil)
    end

    before do
      Gitmine::Issue.stub!(:find => issue)
      Gitmine.stub!(:run_cmd)
    end

    it 'should append the ticket title if only a number is given' do
      Gitmine.should_receive(:run_cmd).with("git checkout -b 1234-Ticket-title")

      Gitmine.branch('1234')
    end

    it 'should raise an exception no number is given' do
      lambda {
        Gitmine.branch('bad-branch-name')
      }.should raise_error("Invalid branch name. It should start with an issue number")
    end
  end
end
