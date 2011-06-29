#Self-join table for echoes.
#The table is inherently hierarchical because it specifies a parent echo and a child echo
#Vibrations are created solely through echoes in order to specify parent echoes

class Vibration < ActiveRecord::Base
  attr_accessible :parent_id, :child_id
  
  belongs_to :parent, :class_name => 'Echo'
  belongs_to :child, :class_name => 'Echo'
  
  validates :parent_id, :presence => true, :numericality => {:only_integer => true, :greater_than => 0}, :uniqueness => {:scope => :child_id}
  validates :child_id, :presence => true, :numericality => {:only_integer => true, :greater_than => 0}
  validate :no_self_vibration

  def no_self_vibration
    if self.parent_id == self.child_id
      self.errors.add(:parent_id, 'cannot be child')
    end
  end
end
