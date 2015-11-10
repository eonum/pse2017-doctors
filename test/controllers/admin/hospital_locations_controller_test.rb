require 'test_helper'

class Admin::HospitalLocationsControllerTest < ActionController::TestCase
  setup do
    @admin_hospital_location = admin_hospital_locations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_hospital_locations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_hospital_location" do
    assert_difference('Admin::HospitalLocation.count') do
      post :create, admin_hospital_location: { address: @admin_hospital_location.address, canton: @admin_hospital_location.canton, doc_id: @admin_hospital_location.doc_id, email: @admin_hospital_location.email, location: @admin_hospital_location.location, name: @admin_hospital_location.name, phone1: @admin_hospital_location.phone1, phone2: @admin_hospital_location.phone2, title: @admin_hospital_location.title }
    end

    assert_redirected_to admin_hospital_location_path(assigns(:admin_hospital_location))
  end

  test "should show admin_hospital_location" do
    get :show, id: @admin_hospital_location
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_hospital_location
    assert_response :success
  end

  test "should update admin_hospital_location" do
    patch :update, id: @admin_hospital_location, admin_hospital_location: { address: @admin_hospital_location.address, canton: @admin_hospital_location.canton, doc_id: @admin_hospital_location.doc_id, email: @admin_hospital_location.email, location: @admin_hospital_location.location, name: @admin_hospital_location.name, phone1: @admin_hospital_location.phone1, phone2: @admin_hospital_location.phone2, title: @admin_hospital_location.title }
    assert_redirected_to admin_hospital_location_path(assigns(:admin_hospital_location))
  end

  test "should destroy admin_hospital_location" do
    assert_difference('Admin::HospitalLocation.count', -1) do
      delete :destroy, id: @admin_hospital_location
    end

    assert_redirected_to admin_hospital_locations_path
  end
end
