require 'test_helper'

class LightSignalTest < ActiveSupport::TestCase
  test 'validates against blank signal' do
    assert !LightSignal.new.save
  end
  test 'validates agaisnt blank ring id' do
    assert !LightSignal.new(:shoutout_id => 1).save
  end
  test 'validates against blank shoutout id' do
    assert !LightSignal.new(:ring_id => 1).save
  end
end
