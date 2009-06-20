module TwitterAuthenticatedSystem
    # Returns true or false if the <%= file_name %> is logged in.
    # Preloads @current_<%= file_name %> with the <%= file_name %> model if they're logged in.
    def logged_in?
      !!current_<%= file_name %>
    end

    # Accesses the current <%= file_name %> from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_<%= file_name %>
      @current_<%= file_name %> ||= login_from_session unless @current_<%= file_name %> == false
    end

    # Store the given <%= file_name %> id in the session.
    def current_<%= file_name %>=(new_<%= file_name %>)
      session[:<%= file_name %>_id] = new_<%= file_name %> ? new_<%= file_name %>.id : nil
      @current_<%= file_name %> = new_<%= file_name %> || false
    end

    def consumer_token
      @consumer_token ||= YAML::load_file("#{RAILS_ROOT}/config/twitter_oauth.yml").symbolize_keys
    end

    def consumer
      OAuth::Consumer.new(
        consumer_token[:consumer_token],
        consumer_token[:consumer_secret],
        {:site => 'http://twitter.com', :authorize_path => '/oauth/authenticate'}
      )
    end

    def redirect_to_twitter_login
      request_token = consumer.get_request_token
     
      reset_session
      session[:request_token] = request_token.token
      session[:request_secret] = request_token.secret

      redirect_to request_token.authorize_url
    end

    def handle_callback
      request_token = OAuth::RequestToken.new(consumer, session[:request_token], session[:request_secret])

      session[:request_token] = nil
      session[:request_secret] = nil

      access_token = request_token.get_access_token

      twitter = Twitter::Base.new(access_token)

      # Twitter user credentials will be resaved to the database on every login
      credentials = twitter.verify_credentials.to_hash
      
      # Clean some attribute names
      credentials['twitter_id'] = credentials.delete('id')
      credentials['login'] = credentials.delete('screen_name')
      credentials['member_since'] = credentials.delete('created_at')
      
      # Remove extra attributes from credentials
      credentials.delete_if { |k, v| !<%= class_name %>.column_names.include? k }

      # Add access token to credentials
      credentials.merge({:access_token => access_token.token, :access_secret => access_token.secret}).symbolize_keys
    end

    # Inclusion hook to make #current_<%= file_name %> and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_<%= file_name %>, :logged_in?
    end

    # Called from #current_<%= file_name %>.  First attempt to login by the <%= file_name %> id stored in the session.
    def login_from_session
      self.current_<%= file_name %> = <%= class_name %>.find_by_id(session[:<%= file_name %>_id]) if session[:<%= file_name %>_id]
    end
end
