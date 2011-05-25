class Gitmine
  class Config
    HOME_CONFIG_FILE = '~/.gitmine.yml'
    CONFIG_FILE = './.gitmine.yml'

    class << self
      def config
        @@config ||= new
      end

      def redmine_host
        config['host']
      end

      def redmine_api_key
        config['api_key']
      end

      def github
        config['github']
      end

      def statuses
        config['statuses']
      end

      def status_reviewed
        config['statuses']['reviewed']
      end
    end

    def initialize
      # Read from the home .gitmine.yml file first, then merge the local file on top of it to provide proper overrides
      home_path = HOME_CONFIG_FILE
      path = CONFIG_FILE
      if File.exists?(home_path)
        @home_config = YAML.load_file(home_path)
      else
        @home_config = {}
      end
      @config = @home_config.merge(YAML.load_file(path))
    end

    def [](key)
      @config[key]
    end

  end # Class Config
end
