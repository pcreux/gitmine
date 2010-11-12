require 'rubygems'

require 'grit'
require 'yaml'
require 'httparty'

%w(gitmine issue commit cli).each do |filename|
  require File.dirname(__FILE__) + "/gitmine/#{filename}.rb"
end
