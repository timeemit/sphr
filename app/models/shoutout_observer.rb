class ShoutoutObserver < ActiveRecord::Observer
  def after_save(shoutout)
    #Insert code that creates signals based on the content of the shoutout.
  end
end