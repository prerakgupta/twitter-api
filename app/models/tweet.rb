class Tweet < ActiveRecord::Base
	belongs_to :user

	def save_new_tweet(params)
		#Save both users and tweet as a transaction
		begin
			@user = User.find_or_initialize_by(:name => params[:user_name], :handle => params[:user_handle], :twitter_id => params[:user_twitter_id])
			@tweet = Tweet.new(:text => params[:tweet_text], :hashtag => params[:tweet_hashtag])
			@user.tweets << @tweet
			@user.save!
		rescue Exception => e
		  #ToDo: handle failure of save
		  binding.pry	
		end
	end
end
