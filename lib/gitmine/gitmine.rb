module Gitmine
  class Gitmine
    def self.list
      gm = Gitmine.new
      gm.commits.each do |commit|
        status = commit.issue ? commit.issue.status : 'N/A'
        puts "#{commit.id[0..6]} #{status.ljust(12)} #{commit.committer.name.ljust(15)} #{commit.message[0..50].gsub("\n", '')}"
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
      config = Issue.config

      raise "Invalid branch name. It should start with the issue number" unless issue_id

      puts "Create the branch #{branch_name}"
      run_cmd("git checkout -b #{branch_name}")

      puts "Push it to origin"
      run_cmd("git push origin #{branch_name}")

      puts "Make the local branch tracking the remote"
      run_cmd("git branch --set-upstream #{branch_name} origin/#{branch_name}")

      puts "Adding a note to the Issue ##{issue_id}"
      note = "Branch *#{branch_name}* created from #{original_branch}"
      if config['github']
        note << %{ - "See on Github":https://github.com/#{config['github']}/tree/#{branch_name}}
        note << %{ - "Compare on Github":https://github.com/#{config['github']}/compare/#{original_branch}...#{branch_name}}
      end

      puts 'Done!' if Issue.find(issue_id).add_note(note)
    end

    # TODO specs
    def self.checkout(issue_id)
      if local_branch = local_branches.select { |branch| branch[/^#{issue_id}-/] }.first
        run_cmd("git checkout #{local_branch}")
        return
      end

      if remote_branch = remote_branches.select { |branch| branch[/^#{issue_id}-/] }.first
        run_cmd("git checkout -b #{remote_branch} origin/#{remote_branch}")
        return
      end

      raise "Can't find branch starting with #{issue_id}"
    end

    # TODO specs
    def self.delete(issue_id)
      if remote_branch = remote_branches.select { |branch| branch[/^#{issue_id}-/] }.first
        run_cmd("git push origin :#{remote_branch}")
      else
        raise "Can't find branch starting with #{issue_id}"
      end
    end

    def self.run_cmd(cmd)
      puts cmd
      exit! unless system(cmd)
    end

    # TODO specs
    def self.local_branches
      branches = []
      `git branch`.each_line do |line|
        if match = line[/\d+.*$/]
          branches << match
        end
      end

      branches
    end

    # TODO specs
    def self.remote_branches
      run_cmd("git fetch")

      branches = []
      `git branch -r`.each_line do |line|
        if match = line.match(/origin\/(\d+.*)/)
          branches << match[1]
        end
      end

      branches
    end
  end
end
