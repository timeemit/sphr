class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  
  has_one :activity, :as => :entity, :dependent => :destroy
  
  after_create :register_action
  
  validates_presence_of :user_id, :post_id, :content
  
  def register_action
    if post.recipient_type == 'User'
      self.create_activity(:user_id => post.user.id, :action => 'created_comment_for_user')
    end
  end
end
