require 'test_helper'

class EchoesControllerTest < ActionController::TestCase
  setup do
    @echo = echoes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:echoes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create echo" do
    assert_difference('Echo.count') do
      post :create, :echo => @echo.attributes
    end

    assert_redirected_to echo_path(assigns(:echo))
  end

  test "should show echo" do
    get :show, :id => @echo.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @echo.to_param
    assert_response :success
  end

  test "should update echo" do
    put :update, :id => @echo.to_param, :echo => @echo.attributes
    assert_redirected_to echo_path(assigns(:echo))
  end

  test "should destroy echo" do
    assert_difference('Echo.count', -1) do
      delete :destroy, :id => @echo.to_param
    end

    assert_redirected_to echoes_path
  end
end
