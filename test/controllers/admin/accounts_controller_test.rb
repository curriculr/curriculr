require 'test_helper'

class Admin::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:main)
    @admin = users(:super)
    sign_in_as(@admin)
  end
  
  teardown do
    sign_out
  end

  test "visit index page" do
    get admin_accounts_url
    assert_response :success
  end

  test "start new account " do
    get new_admin_account_url, xhr: true
    assert_response :success
  end

  test "create account" do
    assert_difference('Account.count') do
      post admin_accounts_url, params: {
        account: {slug: "third", name: "Third Account", about: "Parturient Sem Tristique Consectetur",
        user_attributes: {name: "Third Admin", email: "third_admin@bar.foo", password: "password",
           password_confirmation: "password"}}
      }, xhr: true
      assert_response :success
    end
  end

  test "show account" do
    get admin_account_url(@account)
    assert_response :success
  end

  test "start editing account" do
    get edit_admin_account_url(@account), xhr: true
    assert_response :success
  end

  test "update account" do
    patch admin_account_url(@account), params: { 
      account: { name: "The Third Admin" }
    }, xhr: true
    assert_response :success
    assert_equal "The Third Admin" , Account.find(@account.id).name
  end

  test "cannot delete default account" do
    assert_no_difference('Account.count') do
      delete admin_account_url(@account)
    end

    assert_redirected_to admin_account_url(@account)
  end
  
  test "delete an account" do
    assert_difference('Account.count', -1) do
      delete admin_account_url(accounts(:secondary))
    end

    assert_redirected_to admin_accounts_url()
  end
end
