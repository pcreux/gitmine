class Gitmine
  class HudsonJob
    class Http
      include HTTParty

      base_uri Config.hudson_host
      basic_auth(Config.hudson_username, Config.hudson_password) if Config.hudson_username
      headers 'Content-type' => 'text/xml'
      # I get timeout errors on heroku but not on local env. Is that because of REE-1.8.7 ?
      # Workaround: Set the timeout to 10 seconds and rescue timeout errors.
      default_timeout 8
    end

    def self.all_by_name_including(pattern)
      HudsonJob.all.select { |projects| projects.name[pattern] }
    end

    def self.all
      r = Http.get('/api/xml')
      return [] unless r.code == 200
      r.parsed_response["hudson"]["job"].map do |jobs_data|
        new(jobs_data["name"])
      end
    end

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def delete!
      r = Http.post("/job/#{name}/doDelete")
      raise "Failed to delete job #{name}" unless r.code == 200
      puts green(" - #{name} deleted!")

      true
    end

  end
end
