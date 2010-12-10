class Gitmine::Commit 
  attr_reader :grit_commit

  # Initialize a new Commit objects that delegates methods to the Grit::Commit object passed in
  def initialize(grit_commit)
    @grit_commit = grit_commit
  end

  # Issue associated with this commit
  # Return nil if their is no associated issue
  def issue
    @issue ||= Gitmine::Issue.get_for_commit(message)
  end

  # Delegate #id to Grit::Commit
  def id
    @grit_commit.id
  end

  protected
  # Delegate methods to Grit::Commit
  def method_missing(m, *args, &block)  
    return @grit_commit.send(m, args, block) if @grit_commit.respond_to? m
    super
  end  
end
