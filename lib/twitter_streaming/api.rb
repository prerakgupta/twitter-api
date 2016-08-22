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
        binding.pry
      end
    end

    def start_streaming(hashtag)
      client = get_client
      client.track("#{hashtag}") do |status|
        puts status.text
        #params = get_params(status)
        #Tweet.save_new_tweet(params)
      end
    end

    def get_params(status)
    end
  end
end