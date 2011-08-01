require 'test_helper'
require 'generators'

class UserFlowsTest < ActionDispatch::IntegrationTest
  fixtures :all

  test 'signup' do
    user = User.new(:email => 'L@2.com', :email_confirmation => 'L@2.com')
    post_via_redirect '/users', {:email => user.email, :email_confirmation => user.email_confirmation}
    assert_difference('User.count') do 
      post_via_redirect '/users', {:email => user.email, :email_confirmation => user.email_confirmation}
      assert_equal "/users/#{User.find_by_email(user.email)}/parallax", path
    end  
  end

  test 'signin' do
    skelly = saved_skeleton1
    post_via_redirect "/users/sign_in", :username => skelly.username, :password => 'S1lly'
    assert_response :success
    assert_equal "users/#{skelly.id}/shoutouts", path
  end
end
