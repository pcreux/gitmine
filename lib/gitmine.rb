require 'rubygems'

require 'grit'
require 'yaml'
require 'httparty'

class Gitmine

  def self.list
    gm = Gitmine.new
    gm.commits.each do |commit|
      status = commit.issue.status if commit.issue
      status ||= 'N/A'
      puts "#{commit.id[0..6]} #{status.ljust(12)} #{(commit.committer.name || "").ljust(15)} #{commit.message[0..50].gsub("\n", '')}"
    end
  end

  def initialize
    @repo = Grit::Repo.new(ENV['PWD'])
    @branch = File.read('./.git/HEAD').match(/^ref: refs\/heads\/(.+)/)[1]
  end

  def commits
    @repo.commits(@branch).map do |c|
      Commit.new(c)
    end
  end


  # TODO specs
  def self.branch(branch_name)
    issue_id = branch_name[/^\d+/]
    original_branch = File.read('./.git/HEAD').match(/^ref: refs\/heads\/(.+)/)[1]

    raise "Invalid branch name. It should look like 123-my-branch" unless branch_name[/^\d+-/]

    issue = Issue.find(issue_id)

    raise "Issue ##{issue_id} does not exists" if issue.nil?

    puts yellow("Create the branch #{branch_name}")
    run_cmd("git checkout -b #{branch_name}")

    puts yellow("Push it to origin")
    run_cmd("git push origin #{branch_name}")

    puts yellow("Make the local branch tracking the remote")
    run_cmd("git branch --set-upstream #{branch_name} origin/#{branch_name}")

    puts yellow("Adding a note to the Issue ##{issue_id}")
    note = "Branch *#{branch_name}* created from #{original_branch}"
    if Config.github
      note << %{ - "See on Github":https://github.com/#{Config.github}/tree/#{branch_name}}
      note << %{ - "Compare on Github":https://github.com/#{Config.github}/compare/#{original_branch}...#{branch_name}}
    end

    issue.add_note(note)
  end

  # TODO specs
  def self.checkout(issue_id)
    local_branch = LocalBranch.find(issue_id).name
    if local_branch
      run_cmd("git checkout #{local_branch}")
      return
    end

    remote_branch = RemoteBranch.find(issue_id).name
    if remote_branch
      run_cmd("git checkout -b #{remote_branch} origin/#{remote_branch}")
      return
    end

    raise "Can't find branch starting with #{issue_id}"
  end

  # TODO specs
  def self.delete(issue_id)
    RemoteBranch.find(issue_id).delete
  end

  # TODO specs
  def self.reviewed(issue_id)
    issue = Issue.find(issue_id)

    puts yellow("Merge #{issue_id} to master and push")
    issue.local_branch.merge_to_master

    puts yellow("Delete remote branch")
    issue.remote_branch.delete

    puts yellow("Delete hudson jobs")
    issue.delete_hudson_jobs

    puts yellow("Set Ticket status to 'reviewed'")
    issue.update_status("reviewed")
  end
end


%w(config issue commit cli colors branch git hudson_job).each do |filename|
  require File.dirname(__FILE__) + "/gitmine/#{filename}.rb"
end
