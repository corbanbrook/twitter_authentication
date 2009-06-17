# This controller handles the login/logout function of the site.  
class <%= sessions_class_name %>Controller < ApplicationController
  # Be sure to include TwitterAuthenticationSystem in Application Controller instead
  include TwitterAuthenticatedSystem

  # render new.rhtml
  def new
    reset_session
    oauth = Twitter::OAuth.new('consumer token', 'consumer secret')
    session[:request_token] = oauth.request_token.token
    session[:request_secret] = oauth.request_token.secret
    redirect_to 'http://twitter.com/oauth/authenticate?oauth_token=' + oauth.request_token.token
  end

  def create
    oauth = Twitter::OAuth.new('consumer token', 'consumer secret')
    begin
      oauth.authorize_from_request(session[:request_token], session[:request_secret])
    rescue
      render :text => 'could not authorize.'
    end

    twitter = Twitter::Base.new(oauth)
    login = twitter.verify_credentials.screen_name

    unless @user = <%= class_name %>.find_by_login(login)
      @user = <%= class_name %>.new(:login => login, :token => oauth.access_token.token, :secret => oauth.access_token.secret)
      @user.save
    end

    self.current_<%= file_name %> = @user

    redirect_to root_path
    flash[:notice] = "Logged in successfully"
  end

  def destroy
    reset_session
    
    redirect_to root_path
    flash[:notice] = "You have been logged out."
  end
end
