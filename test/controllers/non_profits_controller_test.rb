require 'test_helper'

class NonProfitsControllerTest < ActionController::TestCase
  setup do
    @non_profit = non_profits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:non_profits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create non_profit" do
    assert_difference('NonProfit.count') do
      post :create, non_profit: { alias: @non_profit.alias, domain_name: @non_profit.domain_name, donation_page_url: @non_profit.donation_page_url, ein: @non_profit.ein, image_url: @non_profit.image_url, name: @non_profit.name, status_code: @non_profit.status_code, tax_exempt: @non_profit.tax_exempt }
    end

    assert_redirected_to non_profit_path(assigns(:non_profit))
  end

  test "should show non_profit" do
    get :show, id: @non_profit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @non_profit
    assert_response :success
  end

  test "should update non_profit" do
    patch :update, id: @non_profit, non_profit: { alias: @non_profit.alias, domain_name: @non_profit.domain_name, donation_page_url: @non_profit.donation_page_url, ein: @non_profit.ein, image_url: @non_profit.image_url, name: @non_profit.name, status_code: @non_profit.status_code, tax_exempt: @non_profit.tax_exempt }
    assert_redirected_to non_profit_path(assigns(:non_profit))
  end

  test "should destroy non_profit" do
    assert_difference('NonProfit.count', -1) do
      delete :destroy, id: @non_profit
    end

    assert_redirected_to non_profits_path
  end
end
