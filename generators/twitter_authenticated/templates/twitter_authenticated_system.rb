module TwitterAuthenticatedSystem
  protected
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
