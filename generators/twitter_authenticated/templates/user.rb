class <%= class_name %> < ActiveRecord::Base
  validates_presence_of     :login
  validates_uniqueness_of   :login, :email, :case_sensitive => false
end
