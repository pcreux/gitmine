class Gitmine
  class HudsonProject
    class Http
      include HTTParty

      base_uri Config.hudson_url
      basic_auth(Config.hudson_username, Hudhub.hudson_password) if Config.hudson_username
      headers 'Content-type' => 'text/xml'
      # I get timeout errors on heroku but not on local env. Is that because of REE-1.8.7 ?
      # Workaround: Set the timeout to 10 seconds and rescue timeout errors.
      default_timeout 8
    end

    def self.find_by_name_including(pattern)
      HudsonProject.all.select { |projects| projects.name[pattern] }
    end

    def self.all

    end

  end
end
