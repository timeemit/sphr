class RingObserver < ActiveRecord::Observer
  def after_create(ring)
    if ring.public_ring == true
      ring.create_profile
    end
  end
end