class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.string :name
    	t.string :handle, :null => false
    	t.string :twitter_id, :null => false
      t.timestamps
    end

    add_index :users, [:handle], :name => :idx_users_handle
  end
end
