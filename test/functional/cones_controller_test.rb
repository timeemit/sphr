require 'test_helper'

class ConesControllerTest < ActionController::TestCase
  setup do
    @cone = cones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cone" do
    assert_difference('Cone.count') do
      post :create, :cone => @cone.attributes
    end

    assert_redirected_to cone_path(assigns(:cone))
  end

  test "should show cone" do
    get :show, :id => @cone.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cone.to_param
    assert_response :success
  end

  test "should update cone" do
    put :update, :id => @cone.to_param, :cone => @cone.attributes
    assert_redirected_to cone_path(assigns(:cone))
  end

  test "should destroy cone" do
    assert_difference('Cone.count', -1) do
      delete :destroy, :id => @cone.to_param
    end

    assert_redirected_to cones_path
  end
end
