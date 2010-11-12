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


    def self.branch(branch_name)
      issue_id = branch_name[/^\d+/]
      original_branch = File.read('./.git/HEAD').match(/^ref: refs\/heads\/(.+)/)[1]
      config = Issue.config

      raise "Invalid branch name. It should start with the issue number" unless issue_id

      puts "Creating the remote branch #{branch_name}"

      run_cmd("git push origin origin:refs/heads/#{branch_name}")
      run_cmd("git checkout --track -b #{branch_name} origin/#{branch_name}")


      puts "Adding a note to the Issue ##{issue_id}"
      note = "Branch *#{branch_name}* created from #{original_branch}"
      if config['github']
        note << %{ - "See on Github":https://github.com/#{config['github']}/tree/#{branch_name}}
        note << %{ - "Compare on Github":https://github.com/#{config['github']}/compare/#{original_branch}...#{branch_name}}
      end

      Issue.find(issue_id).add_note(note)
    end

    def self.run_cmd(cmd)
      puts cmd
      system cmd
    end
  end
end
