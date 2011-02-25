class Gitmine::Git
  class << self
    # Return output of 'git branch'
    def local_branches
      `git branch`
    end

    # Return output of 'git branch -r'
    def remote_branches
      `git branch -r`
    end

    # Run 'git fetch'
    def fetch
      run_cmd("git fetch")
    end

    def checkout(branch)
      run_cmd("git checkout #{branch}")
    end

    def merge(branch)
      run_cmd("git merge #{branch}")
    end

    def push
      run_cmd("git push")
    end

    def pull
      run_cmd("git pull")
    end

    def delete_remote_branch(branch)
      run_cmd("git push origin :#{branch}")
    end
  end
end
