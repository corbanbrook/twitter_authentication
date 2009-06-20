# This controller handles the login/logout function of the site.  
class <%= sessions_class_name %>Controller < ApplicationController
  # Be sure to include TwitterAuthenticationSystem in Application Controller instead
  include TwitterAuthenticatedSystem

  def login
    redirect_to_twitter_login
  end

  def callback
    credentials = handle_callback

    unless @user = <%= class_name %>.find_by_twitter_id(credentials[:twitter_id])
      @user = <%= class_name %>.new(credentials)
      @user.save
    else
      @user.update_attributes credentials
    end

    self.current_<%= file_name %> = @user

    redirect_to root_path
    flash[:notice] = "Logged in successfully"
  end

  def logout
    reset_session
    
    redirect_to root_path
    flash[:notice] = "You have been logged out."
  end
end
