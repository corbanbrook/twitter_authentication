class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>", :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.string :token
      t.string :secret
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime

    end
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end
