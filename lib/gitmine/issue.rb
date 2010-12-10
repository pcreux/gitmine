class Gitmine
  class Issue
    CONFIG_FILE = './.gitmine.yml'

    attr_reader :id, :subject, :status
    
    # Config from .gitmine.yml
    def self.config
      @@config ||= YAML.load_file(CONFIG_FILE)
    end

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
      issue_id ? Issue.find(issue_id) : nil
    end

    # Get the issue from redmine
    def self.find(issue_id)
      Issue.new.tap { |issue|
        issue.build_via_issue_id(issue_id)
      }
    end

    def local_branch
      LocalBranch.find(self.id)
    end

    def remote_branch
      RemoteBranch.find(self.id)
    end

    # Get attributes from redmine and set them all
    def build_via_issue_id(issue_id)
      @id = issue_id
      data = http_get(issue_id).parsed_response['issue']
      if data
        @subject = data['subject']
        @status = data['status']['name']
      end
    end

    # Add a note to the Issue
    def add_note(note)
      response = self.class.put(url(self.id), :query => {:notes => note}, :body => "") # nginx reject requests without body

      if response.code == 200
        return true
      else
        raise response.response
      end
    end

    include HTTParty
    base_uri "#{config['host']}/issues/"
    basic_auth config['api_key'], '' # username is api_key, password is empty
    headers 'Content-type' => 'text/xml' # by-pass rails authenticity token mechanism

    protected

    # Url to redmine/issues
    def url(id)
      "/#{id}.xml"
    end

    def http_get(issue_id)
      self.class.get(url(issue_id))
    end
  end
end
