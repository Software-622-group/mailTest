require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid login information" do
    get sessions_login_path
    assert_no_difference 'User.count' do
      post users_path, user:{
        name: "",
        email: "user@invalid",
        password: "password",
        password_confirmation: "password"
      }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end
  
  test "valid login information" do
    get sessions_login_path
    assert_difference 'User.count', 1 do
      post users_path, user:{
        name: "Test Student",
        email: "student@test.com",
        password: "password",
        password_confirmation: "password"
        
        }
    end
    assert_equal 1,ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    log_in_as(user)
    assert_not is_logged_in?
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    get edit_account_activation_path(user.activation_token, email: user.email) 
    assert user.reload.activated?
    
    assert_redirected_to controller: :homes, action: :index
    follow_redirect!
    assert_template 'homes/index'
    # assert_select "a[href=?]", root_path, count: 2
    # assert_select "a[href=?]", courses_path, count: 1
    assert is_logged_in?
  end
end
