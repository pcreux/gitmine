describe Gitmine::Config do
  describe "#config" do
    it "should load the config from config.yml" do
      Gitmine::Config.redmine_host.should == "http://redmine-gitmine.heroku.com"
      Gitmine::Config.github.should == "pcreux/gitmine"
      Gitmine::Config.bitbucket.should == "davidcollom/paasmaker"
    end
  end
end
