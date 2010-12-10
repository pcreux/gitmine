require 'spec_helper'

describe Gitmine::Branch do
  before do
    Gitmine::Git.stub!(:local_branches) { <<-GIT_OUTPUT
  2632-invoice-should-accept-date
  2675
  * 2869-BUG-accepted-by-not-set
  master
  production
GIT_OUTPUT
    }

    Gitmine::Git.stub!(:remote_branches) { <<-GIT_OUTPUT
  origin/2890-email-aliases
  origin/2915-sanitize-eft-fields
  origin/HEAD -> origin/master
  origin/master
  origin/production
GIT_OUTPUT
    }

    Gitmine::Git.stub!(:fetch)
  end

  describe "#local_branches" do
    it "should return an array of branches starting with digits only" do
      Gitmine::Branch.local_branches.
        should == %w(2632-invoice-should-accept-date 2675 2869-BUG-accepted-by-not-set)
    end
  end

  describe "#remote_branches" do
    it "should return an array of branches starting with digits only" do
      Gitmine::Branch.remote_branches.
        should == %w( 2890-email-aliases 2915-sanitize-eft-fields )
    end
  end

  describe "find_local(issue_id)" do
    context "when the branch exists" do
      it "should return the branch name" do
        Gitmine::Branch.find_local('2632').
          should == '2632-invoice-should-accept-date'
      end
    end

    context "when the does not exists" do
      it "should return nil" do
        Gitmine::Branch.find_local('9999').
          should == nil
      end
    end
  end

  describe "find_remote(issue_id)" do
    context "when the branch exists" do
      it "should return the branch name" do
        Gitmine::Branch.find_remote('2890').
          should == '2890-email-aliases'
      end
    end

    context "when the does not exists" do
      it "should return nil" do
        Gitmine::Branch.find_remote('9999').
          should == nil
      end
      it "should fetch and retry" do
        Gitmine::Git.should_receive(:fetch)
        Gitmine::Branch.should_receive(:clear_memoized_remote_branches!)
        # can't test the recursive call
        Gitmine::Branch.find_remote('9999')
      end
    end
  end

end
