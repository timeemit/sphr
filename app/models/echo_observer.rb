class EchoObserver < ActiveRecord::Observer
  def after_create(echo)
    echo.shoutout.echo_count += 1
  end
  
  def after_destroy
    echo.shoutout.echo_count -= 1    
  end
end
