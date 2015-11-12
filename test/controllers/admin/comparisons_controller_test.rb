require 'test_helper'

class Admin::ComparisonsControllerTest < ActionController::TestCase
  setup do
    @admin_comparison = admin_comparisons(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_comparisons)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_comparison" do
    assert_difference('Admin::Comparison.count') do
      post :create, admin_comparison: { description_de: @admin_comparison.description_de, description_fr: @admin_comparison.description_fr, description_it: @admin_comparison.description_it, name: @admin_comparison.name, name_de: @admin_comparison.name_de, name_fr: @admin_comparison.name_fr, name_it: @admin_comparison.name_it, variables: @admin_comparison.variables }
    end

    assert_redirected_to admin_comparison_path(assigns(:admin_comparison))
  end

  test "should show admin_comparison" do
    get :show, id: @admin_comparison
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_comparison
    assert_response :success
  end

  test "should update admin_comparison" do
    patch :update, id: @admin_comparison, admin_comparison: { description_de: @admin_comparison.description_de, description_fr: @admin_comparison.description_fr, description_it: @admin_comparison.description_it, name: @admin_comparison.name, name_de: @admin_comparison.name_de, name_fr: @admin_comparison.name_fr, name_it: @admin_comparison.name_it, variables: @admin_comparison.variables }
    assert_redirected_to admin_comparison_path(assigns(:admin_comparison))
  end

  test "should destroy admin_comparison" do
    assert_difference('Admin::Comparison.count', -1) do
      delete :destroy, id: @admin_comparison
    end

    assert_redirected_to admin_comparisons_path
  end
end
