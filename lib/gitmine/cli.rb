module Gitmine
  class CLI
    def self.run
      case ARGV[0]
      when nil
        list
      when "branch"
        branch
      else
        puts <<-EOS
  Usage:
  gitmine: show the 10 latest commits and their associated issue status
  gitmine branch [BRANCH_NAME]: create a new branch
  EOS
      end
    end

    def self.list
      Gitmine.list
    end

    def self.branch
      Gitmine.branch(ARGV[1])
    end
  end
end
