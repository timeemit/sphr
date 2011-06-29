class Ring < ActiveRecord::Base
  attr_accessible :number, :public_ring, :name
  
  #Associations
  
  belongs_to :user
  has_many :friendships, :conditions => {:mutual => false}
  has_many :mutual_friendships, :conditions => {:mutual => true}, :class_name => 'Friendship'
  has_many :user_rings, :through => :user, :source => :rings
  has_many :this_and_farther_rings, :through => :user, :source => :rings, :conditions => 'number >= #{self.number}'
  has_many :this_and_closer_rings, :through => :user, :source => :rings, :conditions => 'rings.number <= #{self.number}'

  has_many :shoutouts
  has_many :light_signals
  has_many :extended_light_signals, :through => :shoutouts, :source => :light_signals
  has_many :echoes
  has_many :echoes_of_shoutouts, :through => :shoutouts, :source => :echoes

  has_many :activities
  has_one :profile
  
  #Validations 
  
  #Need to limit the number a rings a user can have
  validates :user_id, :presence => true, :numericality => {:only_integer => true, :greater_than => 0}
  validates :name, :presence => true, :uniqueness => {:scope => :user_id}
  validates :number, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1}
  validate :against_high_number, :on => :create
  validate :against_really_high_number, :on => :update

  #These were replaced with the above validates commands
  # validates_uniqueness_of :number, :scope => :user_id   
  # validates_uniqueness_of :public_ring, :scope => :user_id, :if => Proc.new {|this_ring| this_ring.public_ring == true}
  # validates_presence_of :user_id, :name
  # validates_uniqueness_of :name, :scope => :user_id
  # validates_numericality_of :number, :only_integer => true, :greater_than_or_equal_to => 1
  
  #Callbacks
  
  before_create :control_public_and_set_projected_name
  after_create :shift_other_rings_up
  before_destroy :check_not_public
  after_destroy :shift_other_rings_down
  
  # General usage
  
  #If a user has three rings, ring one will have RGB = (0,0,255), ring two will have RGB = (127,0,127), and ring three will have (255,0,0)
  def color
    #Untested
    count = self.user_rings.count
    parts = count - 1
    rgb = Hash.new
    rgb[:green] = 0
    if self.number == 1
      logger.info "test: number is one"
      rgb[:red] = 0
      rgb[:blue] = 255
    elsif self.number == count
      logger.info "test: number is count"
      rgb[:red] = 255
      rgb[:blue] = 0
    else
      logger.info "test: count = #{count}, number = #{self.number}"
      rgb[:red] = 256*(self.number-1)/parts - 1
      rgb[:blue] = 256*(parts-self.number+1)/parts - 1 
    end
    return rgb
  end
  
  #Returns rgb value string for color
  def rgb
    return "rgb(#{self.color[:red]},#{self.color[:green]},#{self.color[:blue]})"
  end
  
  private
  
  # Validations
  
  #New rings with numbers that are too high ( > rings.count) should not be made.
  def against_high_number
    #The exception is when there are no rings at all.  This is to ensure that a first ring can be constructed.
    unless self.user.nil?
      unless self.user.rings.count == 0
        if self.number > self.user.rings.count
          errors.add(:number, 'too high')
        end
      end
    end
  end
  #Updated rings need to be able to reach rings.count + 1 so that a shift can occur.
  def against_really_high_number
    if self.number > self.user.rings.count + 1
      errors.add(:number, 'way too high')
    end
  end

  # Before create
  
  #Sets the public_ring value of self to true if it is the first ring of the user
  def control_public_and_set_projected_name
    #The first ring made becomes public and its value is set to 1
    if self.user.rings(true).empty?
      self.number = 1
      self.name = 'Public'
      self.public_ring = true
    else
      # self.update_attributes(:public_ring => false)
      self.public_ring = false
    end
    self.projected_name = self.user.username
    return true
  end

  #Increments the numbers of rings of equal distance or farther.
  def shift_other_rings_up
    (self.user.rings(true).count - self.number).times do |i|
      #Note that there is ANOTHER saved ring with the same number as self that needs to be shifted.
      #In the following search by association, IT should be called instead of self because the order is 
      unless self.user_rings.find_by_number(i + self.number).update_attributes(:number => 1 + i + self.number)
        #This block will undo the shift if the other rings are unable to update and then delete the ring
        #NEEDS to be tested somehow
        i.times do |j|
          self.user.rings.find_by_number(1 + i + self.number).update_attributes(:number => i + self.number)
          self.delete
          break
        end
      end
    end
  end

  # Before destroy
  def check_not_public
    if self.public_ring == true
      return false
    else
      check_no_associations
    end
  end
  
  #Returns false if the ring has any friendships, mutual_friendships, activities, or a profile.
  def check_no_associations
    unless self.friendships.empty? and self.mutual_friendships.empty? and self.activities.empty? and self.profile.nil?
      return false
    end
  end
  
  # After destroy
  
  #Decrements the number of all rings farther than self.
  def shift_other_rings_down
    (self.user.rings(true).count - self.number + 1).times do |i|
      #Note that there is ANOTHER saved ring with the same number as self that needs to be shifted.
      #In the following search by association, IT should be called instead of self because the order is 
      unless self.user_rings.find_by_number(1 + i + self.number).update_attributes(:number => i + self.number)
        #This block will undo the shift if the other rings are unable to update and then delete the ring
        #NEEDS to be tested somehow
        i.times do |j|
          self.user.rings.find_by_number(i + self.number).update_attributes(:number => 1+ i + self.number)
          self.delete
          break
        end
      end
    end

    # i = 0
    # self.user_rings.order('number ASC').each do |ring|
    #   i += 1
    #   if ring.number > i
    #     ring.update_attributes(:number => i)
    #   end
    # end
  end  
end