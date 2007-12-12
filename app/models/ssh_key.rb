class SshKey < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id, :key
  validates_format_of   :key, :with => /^ssh-[a-z0-9]{3,4} .+$/ims
  
  before_save :lint_key!
  
  def wrapped_key(cols=72)
    key.gsub(/(.{1,#{cols}})/, "\\1\n").strip
  end
  
  def to_key
    %Q{### START KEY #{self.id || "nil"} ###\n} + 
    %Q{command="gitorious #{user.login}",no-port-forwarding,} + 
    %Q{no-X11-forwarding,no-agent-forwarding,no-pty #{key}} + 
    %Q{\n### END KEY #{self.id || "nil"} ###}
  end  
  
  protected
    def lint_key!
      key.gsub!(/\n+/ms, "")
    end
end