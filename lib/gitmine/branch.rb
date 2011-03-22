class Gitmine
  class Branch
    class << self
      def find(issue_id)
        new(issue_id)
      end

      # TODO: specs
      # Return local branch name for issue_id
      def find_local(issue_id)
        local_branches.select { |branch| branch[/^#{issue_id}-/] }.first
      end

      # TODO: specs
      # Return remote branch name for issue_id
      def find_remote(issue_id)
        remote_branch = remote_branches.select { |branch| branch[/^#{issue_id}-/] }.first
        unless remote_branch
          # Fetch and retry
          Git.fetch
          clear_memoized_remote_branches!
          remote_branch = remote_branches.select { |branch| branch[/^#{issue_id}-/] }.first
        end

        remote_branch
      end


      # Return an array of local branches starting with digits
      # Example
      #   ['123-my-branch', '1234-your-branch']
      # TODO specs
      def local_branches
        return @@local_branches if defined?(@@local_branches) && @@local_branches
        branches = []
        Git.local_branches.each_line do |line|
          if match = line[/\d+.*$/]
            branches << match
          end
        end

        @@local_branches = branches
      end

      # Return an array of remote branches
      # TODO specs
      def remote_branches
        return @@remote_branches if defined?(@@remote_branches) && @@remote_branches
        branches = []
        Git.remote_branches.each_line do |line|
          if match = line.match(/origin\/(\d+.*)/)
            branches << match[1]
          end
        end

        @@remote_branches = branches
      end

      protected

      def clear_memoized_remote_branches!
        @@remote_branches = nil
      end
    end # class methods

    attr_accessor :issue_id

    def initialize(issue_id)
      @issue_id = issue_id
    end

    def local
      LocalBranch.new(issue_id)
    end

    def remote
      RemoteBranch.new(issue_id)
    end
  end

  class LocalBranch < Branch
    def name
      @name ||= Branch.find_local(issue_id)
    end

    def merge_to_master
      Git.checkout("master")
      Git.pull
      Git.merge(self.name)
      Git.push
    end
  end

  class RemoteBranch < Branch
    def name
      @name ||= Branch.find_remote(issue_id)
    end

    def delete
      Git.delete_remote_branch(self.name)
    end
  end
end
