class Gitmine
  class Config
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

      def hudson_host
        config['hudson_host']
      end

      def hudson_username
        config['username']
      end

      def hudson_password
        config['password']
      end
    end

    def initialize
      path = File.join(File.dirname(__FILE__), '..', '..', CONFIG_FILE)
      @config = YAML.load_file(path)
    end

    def [](key)
      @config[key]
    end

  end # Class Config
end
