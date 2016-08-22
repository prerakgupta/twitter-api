class CrunchTweetsController < ApplicationController

  include TwitterStreaming::Api

  def index
  end
  
  def tag
    if params["hashtag"]
      begin
        pid = fork do
          start_streaming(params["hashtag"])
        end
        session[:pid] = pid
        puts "Started new process with id #{pid} for hashtag #{params['hashtag']}."
        status = {:success => true, :pid => pid}
      rescue => ex
        puts "ERROR: in starting the process #{ex.class}=#{ex.message}"
        binding.pry
      end
    else
      status = {:success => false, :message => "Insufficient params"}
    end
    respond_to do |format|
      format.json {render :json => status.to_json }
    end
  end

  def update_stats
    begin
      total_tweets = Tweet.where(:hashtag => params["hashtag"]).count
      user_with_most_tweets = Tweet.find_by_sql("select count(*) as count, user_id from tweets where hashtag = \'#{params['hashtag'].to_s}\' group by user_id order by count limit 1").first.try(:user).try(:handle)
      success = true
    rescue => ex
      puts "ERROR: in updating stats for #{params['hashtag']} with #{ex.class}=#{ex.message}"
      success = false
    end
    #puts "#{{:success => success, :total_tweets => total_tweets.to_i, :user_with_most_tweets => user_with_most_tweets.to_s}.inspect}"
    
    respond_to do |format|
      format.json { render :json => {:success => success, :total_tweets => total_tweets.to_i, :user_with_most_tweets => user_with_most_tweets.to_s}.to_json }
    end
  end

  def stop
    process_id = ( params["pid"] || session[:pid] )
    if process_id
      kill_process(process_id.to_i)
    else
      puts "Could not find process id to kill!"
    end
    redirect_to "/"
  end

  private
    def kill_process(pid)
      begin
        puts "KILLING: process with id #{pid}"
        Process.kill "TERM", pid
        # you have to wait for its termination, otherwise it will become a zombie process
        Process.wait pid
      rescue => ex
        puts "ERROR: Couldn't kill #{pid}. #{ex.class}=#{ex.message}"
      end
    end
end