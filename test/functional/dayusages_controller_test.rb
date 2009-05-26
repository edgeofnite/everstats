require 'test_helper'

class DayusagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dayusages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dayusage" do
    assert_difference('Dayusage.count') do
      post :create, :dayusage => { }
    end

    assert_redirected_to dayusage_path(assigns(:dayusage))
  end

  test "should show dayusage" do
    get :show, :id => dayusages(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => dayusages(:one).to_param
    assert_response :success
  end

  test "should update dayusage" do
    put :update, :id => dayusages(:one).to_param, :dayusage => { }
    assert_redirected_to dayusage_path(assigns(:dayusage))
  end

  test "should destroy dayusage" do
    assert_difference('Dayusage.count', -1) do
      delete :destroy, :id => dayusages(:one).to_param
    end

    assert_redirected_to dayusages_path
  end
end
