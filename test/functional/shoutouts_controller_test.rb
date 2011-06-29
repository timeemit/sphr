require 'test_helper'

class ShoutoutsControllerTest < ActionController::TestCase
  setup do
    @shoutout = shoutouts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shoutouts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shoutout" do
    assert_difference('Shoutout.count') do
      post :create, :shoutout => @shoutout.attributes
    end

    assert_redirected_to shoutout_path(assigns(:shoutout))
  end

  test "should show shoutout" do
    get :show, :id => @shoutout.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @shoutout.to_param
    assert_response :success
  end

  test "should update shoutout" do
    put :update, :id => @shoutout.to_param, :shoutout => @shoutout.attributes
    assert_redirected_to shoutout_path(assigns(:shoutout))
  end

  test "should destroy shoutout" do
    assert_difference('Shoutout.count', -1) do
      delete :destroy, :id => @shoutout.to_param
    end

    assert_redirected_to shoutouts_path
  end
end
