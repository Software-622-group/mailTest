class AccountActivationsController < ApplicationController
    def edit
        user = User.find_by(email: params[:email])
        # user = User.find_by(email: "student1006@test.com")
        # #  puts "```````````````````````````````````````````````"
        #     puts "user is nil"
        #     puts user.nil?
        #     puts "user.activation_token"
        #     puts "user params"
        #     puts params[:id]
        #     puts "```````````````````````````````````````````````"
        #     puts "!user.activated"
        #     puts !user.activated?
        #     puts user.authenticated?(:activation, params[:id])
        puts user
        puts !user.activated?
        puts user.authenticated?(:activation, params[:id])
            
        if user && !user.activated? && user.authenticated?(:activation, params[:id])
            
              
            user.activate
            log_in user
            
            flash[:success] = "Account activated!"
            redirect_to root_url
        else
            flash[:danger] = "Invalid activation link"
            redirect_to root_url
        end
    end
end
