HOST = 'https://redmine.versapay.com'
PROJECT = 'eft'
USERNAME = 'philippe.creux'
PASSWORD = 'temporary_stuff'

class Gitmine
  def initialize
    @repo = Grit::Repo.new(ENV['PWD'])
  end

  def commits
    @repo.commits
  end
end

class Issue
  attr_accessor :id, :subject
end

class Redmine
  CONFIG_FILE = './.gitmine.yml'

  def config
    @config ||= YAML.load_file(CONFIG_FILE)
  end

  def issues_for_commit(commit)
    p url = "#{config['host']}/projects/#{config['project']}/repository/revisions/#{commit.id}.json"
    pp HTTParty.get(url, {:basic_auth => {:username => config[:username], :password => config[:password]}})
  end
end
