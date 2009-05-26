require 'test_helper'

class SlicegroupsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:slicegroups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create slicegroup" do
    assert_difference('Slicegroup.count') do
      post :create, :slicegroup => { }
    end

    assert_redirected_to slicegroup_path(assigns(:slicegroup))
  end

  test "should show slicegroup" do
    get :show, :id => slicegroups(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => slicegroups(:one).to_param
    assert_response :success
  end

  test "should update slicegroup" do
    put :update, :id => slicegroups(:one).to_param, :slicegroup => { }
    assert_redirected_to slicegroup_path(assigns(:slicegroup))
  end

  test "should destroy slicegroup" do
    assert_difference('Slicegroup.count', -1) do
      delete :destroy, :id => slicegroups(:one).to_param
    end

    assert_redirected_to slicegroups_path
  end
end
