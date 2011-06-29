#A signal indicates to a recipient that he/she has been mentioned in a shoutout.

#Give light signals a 'label' or an 'encryption.'  
# I.e.  I should be able signal Liam Norris in a shoutout but in the text it just says 'a boy.'

class LightSignal < ActiveRecord::Base
  belongs_to :shoutout
  belongs_to :ring
  has_one :recipient, :through => :ring, :source => :user
  has_many :activities
  
  validates :shoutout_id, :presence => true, :numericality => {:only_integer => true, :greater_than => 0}
  validates :ring_id, :presence => true, :numericality => {:only_integer => true, :greater_than => 0}
  
  private

  def make_echo
    self.ring.echoes.create(:ring_id => self.ring_id, :shoutout_id => self.shoutout_id, :signalled => true)
    self.destroy
  end
end
