$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

#ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)

require 'rubygems'
require "bundler"
Bundler.require

require 'gitmine'

Rspec.configure do |config|
  config.mock_with :rspec
end

Issue::CONFIG_FILE = File.join(File.dirname(__FILE__), 'config.yml')
