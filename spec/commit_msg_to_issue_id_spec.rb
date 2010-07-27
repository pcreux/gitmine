require 'spec_helper'

describe "CommitMsgToIssueId" do
  describe "#parse" do
    [
      ['Commit message Issue #123.', '123'],
      ['Commit message #123.', nil],
      ['Add method #yey Commit message Issue #123.', '123']
    ].each do |msg, id|
      it "should return #{id} for '#{msg}'" do
        Gitmine::Issue.parse_for_issue_id(msg).should == id
      end
    end
  end
end
