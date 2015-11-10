require 'test_helper'

class Admin::HospitalsControllerTest < ActionController::TestCase
  setup do
    @admin_hospital = admin_hospitals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_hospitals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_hospital" do
    assert_difference('Admin::Hospital.count') do
      post :create, admin_hospital: { address1: @admin_hospital.address1, address2: @admin_hospital.address2, bfs_typo: @admin_hospital.bfs_typo, canton: @admin_hospital.canton, name: @admin_hospital.name }
    end

    assert_redirected_to admin_hospital_path(assigns(:admin_hospital))
  end

  test "should show admin_hospital" do
    get :show, id: @admin_hospital
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_hospital
    assert_response :success
  end

  test "should update admin_hospital" do
    patch :update, id: @admin_hospital, admin_hospital: { address1: @admin_hospital.address1, address2: @admin_hospital.address2, bfs_typo: @admin_hospital.bfs_typo, canton: @admin_hospital.canton, name: @admin_hospital.name }
    assert_redirected_to admin_hospital_path(assigns(:admin_hospital))
  end

  test "should destroy admin_hospital" do
    assert_difference('Admin::Hospital.count', -1) do
      delete :destroy, id: @admin_hospital
    end

    assert_redirected_to admin_hospitals_path
  end
end
