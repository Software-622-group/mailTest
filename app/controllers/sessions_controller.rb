class SessionsController < ApplicationController
  include SessionsHelper

  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
       log_in user
       params[:session][:remember_me] == '1' ? remember_user(user) : forget_user(user)
       flash= {:info => "欢迎回来: #{user.name} :)"}
      # redirect_to root_url,  :flash => flash
      else
        message = "Account not activated"
        message+="Check your email for the activation link."
        flash[:warning] = message
        # redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      # render 'new'
    end
    redirect_to root_url, :flash => flash
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

end
