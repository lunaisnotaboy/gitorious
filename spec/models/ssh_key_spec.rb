require File.dirname(__FILE__) + '/../spec_helper'

describe SshKey do
  
  def create_key(opts={})
    SshKey.new({
      :user_id => 1,
      :key => "ssh-rsa bXljYWtkZHlpemltd21vY2NqdGJnaHN2bXFjdG9zbXplaGlpZnZ0a3VyZWFzc2dkanB4aXNxamxieGVib3l6Z3hmb2ZxZW15Y2FrZGR5aXppbXdtb2NjanRiZ2hzdm1xY3Rvc216ZWhpaWZ2dGt1cmVhc3NnZGpweGlzcWpsYnhlYm95emd4Zm9mcWU= foo@example.com",
    }.merge(opts))
  end

  it "should have a valid ssh key" do
    key = create_key
    key.key = ""
    key.should_not be_valid
    key.key = "foo bar@baz"
    key.should_not be_valid
    
    key.key = "ssh-rsa asdasdasdasd bar@baz"
    key.should be_valid
  end
  
  it "should have a user to be valid" do
    key = create_key
    key.user_id = nil
    key.should_not be_valid
    
    key.user_id = users(:johan).id
    key.valid?
    key.should be_valid
  end
  
  it "strips newlines before save" do
    ssh = create_key(:key => "ssh-rsa bXljYWtkZHlpemltd21vY2NqdGJnaHN2bXFjdG\n9zbXplaGlpZnZ0a3VyZWFzc2dkanB4aXNxamxieGVib3l6Z3hmb2ZxZW15Y2FrZGR5aXppbXdtb2NjanRiZ2hzdm1xY3Rvc216ZWhpaWZ2dGt1cm\nVhc3NnZGpweGlzcWpsYnhlYm95emd4Zm9mcWU= foo@example.com")
    ssh.save
    ssh.key.should_not include("\n")
  end
    
  it "wraps the key at 72 for display" do
    ssh = create_key
    ssh.wrapped_key.should include("\n")
  end
  
  it "returns a proper ssh key with to_key" do
    ssh_key = create_key
    ssh_key.save!
    exp_key = %Q{### START KEY #{ssh_key.id} ###\n} + 
      %Q{command="gitorious #{users(:johan).login}",no-port-forwarding,} + 
      %Q{no-X11-forwarding,no-agent-forwarding,no-pty #{ssh_key.key}} + 
      %Q{\n### END KEY #{ssh_key.id} ###}
    ssh_key.to_key.should == exp_key
  end
end