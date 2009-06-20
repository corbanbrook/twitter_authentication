class <%= class_name %> < ActiveRecord::Base
  def twitter
    consumer_token = YAML::load_file("#{RAILS_ROOT}/config/twitter_oauth.yml").symbolize_keys
    #oauth = Twitter::OAuth.new(consumer_token[:consumer_key], consumer_token[:consumer_secret])
    #oauth.authorize_from_access(token, secret)
    consumer = OAuth::Consumer.new(consumer_token[:consumer_token], consumer_token[:consumer_secret])
    access = OAuth::AccessToken.new(consumer, access_token, access_secret)
    Twitter::Base.new(OAuth::AccessToken.new(access))
  end
end
