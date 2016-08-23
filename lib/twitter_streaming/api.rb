module TwitterStreaming
  module Api

    def get_client
      credentials = CONFIG["twitter_admin"]
      begin
        TweetStream.configure do |config|
          config.consumer_key       = credentials["consumer_key"]
          config.consumer_secret    = credentials["consumer_secret"]
          config.oauth_token        = credentials["oauth_token"]
          config.oauth_token_secret = credentials["oauth_token_secret"]
          config.auth_method        = :oauth
        end
        return TweetStream::Client.new
      rescue Exception => e
        puts "FATAL ERROR: Failed to create Tweetstream client."
      end
      return nil
    end

    def start_streaming(hashtag)
      client = get_client
      return if client.blank?
      begin
        puts "Starting stream.."

        client.on_reconnect do |timeout, retries|
          sleep(timeout.to_i)
          puts "Reconnecting #{retries}"
        end.track("##{hashtag}") do |status|
          next if ( status.class.to_s.downcase.match(/tweet/).blank? || status.user.blank? || !has_hashtag?(status, hashtag) )
          params = get_params(status, hashtag)
          Tweet.new.save_new_tweet(params)
          puts params.inspect
        end
      rescue Exception => e
        puts "FATAL ERROR: Tweetstream stopped with exception! #{e.class} => #{e.message}"
      end
    end

    def get_params(tweet, hashtag)
      name = tweet.user.name.to_s
      handle = tweet.user.screen_name.to_s
      user_id = tweet.user.id.to_s
      text = tweet.text.to_s
      return {:user_twitter_id => user_id, :user_name => name, :user_handle => handle, :tweet_text => text, :tweet_hashtag => hashtag}
    end

    def has_hashtag?(tweet, hashtag)
      all_hashtags = (tweet.hashtags? ? tweet.hashtags.map(&:text).map(&:downcase) : [])
      return ( all_hashtags.include?(hashtag.downcase) )
    end
  end
end