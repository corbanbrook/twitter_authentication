class <%= users_class_name %>Controller < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include TwitterAuthenticatedSystem
end
