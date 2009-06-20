# This controller handles the login/logout function of the site.  
class <%= sessions_class_name %>Controller < ApplicationController
  # Be sure to include TwitterAuthenticationSystem in Application Controller instead
  include TwitterAuthenticatedSystem

  def login
    if consumer_authorized?
      redirect_to_twitter_login
    else
      # twitter did not accept your consumer key and secret, check config/twitter_oauth
      redirect_to root_path
      flash[:notice] = "Application not authorized to access twitter."
    end
  end

  def callback
    credentials = handle_callback

    unless @user = <%= class_name %>.find_by_twitter_id(credentials[:twitter_id])
      @user = <%= class_name %>.new(credentials)
    else
      @user.attributes = credentials
    end

    if @user.save
      self.current_<%= file_name %> = @user
      redirect_to root_path
      flash[:notice] = "Logged in successfully"
    else
      redirect_to root_path
      flash[:notice] = "Login failed."
    end
  end

  def logout
    reset_session
    
    redirect_to root_path
    flash[:notice] = "You have been logged out."
  end
end
