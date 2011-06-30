class UserObserver < ActiveRecord::Observer
  def after_create(user)
    # Send Email to user.email! with confimation 
  end
  
  def after_update(user)
    unless user.activated == true
      user.rings.create(:number => 1, :name => 'Public', :public_ring => true) #This is the public ring.  It should trigger the creation of the public profile.
      user.rings.create(:number => 1, :name => 'Friends')
      user.rings.create(:number => 2, :name => 'Acquaintances') #Now the public ring's number should be 3
      user.cones.create(:name => 'Work')
      user.cones.create(:name => 'School')
      user.cones.create(:name => 'Family')
      user.update_attributes(:activated => true)
    end
  end   
end