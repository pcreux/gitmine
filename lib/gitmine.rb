require 'rubygems'

require 'grit'
require 'yaml'
require 'HTTParty'

class Gitmine
  def self.run
    gm = Gitmine.new
    gm.commits.each do |commit|
      issue = Issue.get_for_commit(commit.message)
      status = issue ? issue.status : 'N/A'
      puts "#{commit.id[0..6]} #{status.ljust(12)} #{commit.committer.name.ljust(15)} #{commit.message[0..50].gsub("\n", '')}"
    end
  end

  def initialize
    @repo = Grit::Repo.new(ENV['PWD'])
  end

  def commits
    @repo.commits
  end
end

module CommitMsgToIssueId
  def self.parse(msg)
    match = msg.match(/Issue #(\d+)/)
    match ? match[1] : nil
  end
end

class Issue
  attr_accessor :id, :subject, :status

  def self.get_for_commit(commit_message)
    issue_id = CommitMsgToIssueId.parse(commit_message)
    issue_id ? Issue.get(issue_id) : nil
  end

  def self.get(issue_id)
    Issue.new.tap { |issue|
      issue.build_via_issue_id(issue_id)
    }
  end

  def config
    @config ||= YAML.load_file(CONFIG_FILE)
  end

  def build_via_issue_id(issue_id)
    @id = issue_id
    data = get(issue_id).parsed_response['issue']
    @subject = data['subject']
    @status = data['status']['name']
  end

  protected

  def url(id)
    "#{config['host']}/issues/#{id}.xml?key=#{config['api_key']}"
  end

  def get(issue_id)
    HTTParty.get(url(issue_id))
  end

  CONFIG_FILE = './.gitmine.yml'

  def issues_for_commit(commit_id)
  end
end
