class Gitmine::CLI
  def self.run
    case ARGV[0]
    when "log"
      list
    when "branch", "br"
      branch
    when "checkout", "co"
      checkout
    when "delete", "del"
      delete
    when "for_deploy", "reviewed"
      reviewed
    else
      puts <<-EOS
Usage:
gitmine branch BRANCH_NAME
  Create a new branch, push to origin, add github links to gitmine ticket
  Example: gitmine branch 1234-my-branch

gitmine checkout ISSUE_ID
  Checkout remote/local branch starting with ISSUE_ID
  Example: gitmine checkout 1234

gitmine reviewed ISSUE_ID
  Merge the branch to master, delete remote branch, update redmine issue status
  Example: gitmine reviewed 1234

gitmine delete ISSUE_ID
  Delete remote branch starting with ISSUE_ID
  Example: gitmine delete 1234

gitmine log
  Displays latest 10 commits and the status of their associated Redmine tickets
EOS
    end
  end

  def self.list
    Gitmine.list
  end

  def self.branch
    Gitmine.branch(ARGV[1])
  end

  def self.checkout
    Gitmine.checkout(ARGV[1])
  end

  def self.delete
    Gitmine.delete(ARGV[1])
  end

  def self.reviewed
    Gitmine.reviewed(ARGV[1])
  end
end
