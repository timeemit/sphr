class ConeConnection < ActiveRecord::Base
  attr_accessible :cone_id, :friendship_id
  
  belongs_to :cone
  belongs_to :friendship
  
  validate :check_validity
  validates_numericality_of :cone_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :friendship_id, :only_integer => true, :greater_than => 0

  private
  
  def check_validity
    if self.cone.blank? and friendship.blank?
      self.errors.add(:cone_id, 'cannot be blank')
      self.errors.add(:friendship_id, 'cannot be blank')
    elsif cone.blank?
      self.errors.add(:cone_id, 'cannot be blank')
    elsif friendship.blank?
      self.errors.add(:friendship_id, 'cannot be blank')
    else
      if ConeConnection.exists?(:friendship_id => friendship_id, :cone_id => cone_id)
        self.errors.add(:cone_id, 'has already been assigned this friend')
        self.errors.add(:friendship_id, 'has already been assigned to this cone')
      end
    end
  end
end
