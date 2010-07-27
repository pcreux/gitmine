require 'rubygems'

require 'grit'
require 'yaml'
require 'HTTParty'

class Gitmine
  # CLI interface
  def self.run
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


  class Commit 
    attr_reader :grit_commit

    # Initialize a new Commit objects that delegates methods to the Grit::Commit object passed in
    def initialize(grit_commit)
      @grit_commit = grit_commit
    end

    # Issue associated with this commit
    # Return nil if teir is no associated issue
    def issue
      @issue ||= Issue.get_for_commit(message)
    end

    # Delegate #id to Grit::Commit
    def id
      @grit_commit.id
    end

    protected
    # Delegate methods to Grit::Commit
    def method_missing(m, *args, &block)  
      return @grit_commit.send(m, args, block) if @grit_commit.respond_to? m
      super
    end  
  end

  class Issue
    CONFIG_FILE = './.gitmine.yml'

    attr_reader :id, :subject, :status

    # Extract the issue_id from a commit message.
    # Examples:
    #   CommitMsgToIssueId.parse("Message for Issue #123.")
    #     => 123
    #   CommitMsgToIssueId.parse("#123.")
    #     => nil
    #
    def self.parse_for_issue_id(msg)
      match = msg.match(/Issue #(\d+)/)
      match ? match[1] : nil
    end

    # Parse the commit_message and get the associated issue if any.
    def self.get_for_commit(commit_message)
      issue_id = parse_for_issue_id(commit_message)
      issue_id ? Issue.get(issue_id) : nil
    end

    # Get the issue from redmine
    def self.get(issue_id)
      Issue.new.tap { |issue|
        issue.build_via_issue_id(issue_id)
      }
    end

    # Config from .gitmine.yml
    def config
      @config ||= YAML.load_file(CONFIG_FILE)
    end

    # Get attributes from redmine and set them all
    def build_via_issue_id(issue_id)
      @id = issue_id
      data = get(issue_id).parsed_response['issue']
      @subject = data['subject']
      @status = data['status']['name']
    end

    protected

    # Url to redmine/issues
    def url(id)
      "#{config['host']}/issues/#{id}.xml?key=#{config['api_key']}"
    end

    # http_get the issue using HTTParty
    def get(issue_id)
      HTTParty.get(url(issue_id))
    end
  end

end
