require 'test_helper'

class Admin::AdminController < ApplicationController::TestCase
  setup do
    @admin = admin(:one)
  end

  test 'should redirect if doctor' do
    get :admin_only, {'current_user.is_admin' => false},{'current_user.email' => "asdf@qualitaetsmedizin.ch"}
    assert(redirect?)
  end

  test "should get doctor path" do
    get :get_doctor_path, {'current_user.is_admin' => false},{'current_user.email' => "asdf@qualitaetsmedizin.ch"}
    assert_equal"/de/admin/doctors/asdf", @response
  end

  test "should select admin layout" do
    get :select_layout, {'current_user.is_admin' => true}

    assert_equal"admin", @response
  end

  test "should select doctor_user layout" do
    get :select_layout, {'current_user.is_admin' => false}

    assert_equal"doctor_user", @response
  end


end
