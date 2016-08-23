class Tweet < ActiveRecord::Base
  belongs_to :user

  def save_new_tweet(params)
    #Save both users and tweet as a transaction
    begin
      @user = User.find_or_initialize_by(:twitter_id => params[:user_twitter_id])
      @user.update_attributes(:name => params[:user_name], :handle => params[:user_handle])
      @tweet = Tweet.new(:text => params[:tweet_text], :hashtag => params[:tweet_hashtag])
      @user.tweets << @tweet
      @user.save!
    rescue Exception => e
      puts "Failed to save tweet #{params.inspect} because of #{e.class} => #{e.message}"
    end
  end
end