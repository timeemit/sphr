class ActivityObserver < ActiveRecord::Observer
  observe :friendship, :profile
  
  def after_create(entity)
    # entity.create_activity(:ring_id => ring_id, :action => 'created_mutual_friendship')
    # entity.activities.create(:ring_id => ring_id, :action => 'created_profile')
  end
  
  def after_update(entity)
    # self.activities.create(:ring_id => ring_id, :action => 'updated_profile')
  end
end