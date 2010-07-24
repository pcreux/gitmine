require 'rubygems'
require "bundler"
Bundler.require

require 'lib/gitmine'

class Commit
  attr_accessor :id
end

c = Commit.new
c.id = 'ecaffffab7b15fb4562d80ce2a30492e2e0a8beb'

Redmine.new.issues_for_commit(c)
