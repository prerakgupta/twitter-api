class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :text
      t.string :hashtag, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end

    add_index :tweets, [:hashtag], :name => :idx_tweets_hashtag
  end
end