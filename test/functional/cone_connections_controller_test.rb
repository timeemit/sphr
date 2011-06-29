require 'test_helper'

class ConeConnectionsControllerTest < ActionController::TestCase
  setup do
    @cone_connection = cone_connections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cone_connections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cone_connection" do
    assert_difference('ConeConnection.count') do
      post :create, :cone_connection => @cone_connection.attributes
    end

    assert_redirected_to cone_connection_path(assigns(:cone_connection))
  end

  test "should show cone_connection" do
    get :show, :id => @cone_connection.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cone_connection.to_param
    assert_response :success
  end

  test "should update cone_connection" do
    put :update, :id => @cone_connection.to_param, :cone_connection => @cone_connection.attributes
    assert_redirected_to cone_connection_path(assigns(:cone_connection))
  end

  test "should destroy cone_connection" do
    assert_difference('ConeConnection.count', -1) do
      delete :destroy, :id => @cone_connection.to_param
    end

    assert_redirected_to cone_connections_path
  end
end
