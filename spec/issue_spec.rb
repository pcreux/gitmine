require 'spec_helper'

describe Issue do
  let(:issue) { Issue.new }
  it "should have an id" do
    issue.should respond_to :id
  end
  it "should have a subject" do
    issue.should respond_to :subject
  end
end
