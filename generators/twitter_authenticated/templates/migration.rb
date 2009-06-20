class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>", :force => true do |t|
      t.integer :twitter_id
      t.string :login
      t.string :name
      t.string :url
      t.string :description
      t.string :location
      t.string :profile_image_url

      t.string :time_zone
      t.integer :utc_offset

      t.integer :followers_count
      t.integer :statuses_count
      t.integer :friends_count
      t.integer :favourites_count
      t.integer :following

      t.boolean :notifications
      t.boolean :protected
      t.boolean :verified

      t.string :access_token
      t.string :access_secret

      t.datetime :member_since
      t.timestamps
    end
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end
