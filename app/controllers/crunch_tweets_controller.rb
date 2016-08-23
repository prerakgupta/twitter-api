class CrunchTweetsController < ApplicationController

  include TwitterStreaming::Api

  def index
  end
  
  def tag
    if params["hashtag"]
      cleanup
      hashtag = sanitize_for_hash(params["hashtag"])
      #Starting a twitter stream in background
      fork = system("RAILS_ENV=production rails runner lib/fork.rb #{hashtag}")
      status = ( fork ? {:success => true} : {:success => false, :message => "Could not start a fork"} )
    else
      status = {:success => false, :message => "Insufficient params"}
    end
    render :json => status.to_json
  end

  def update_stats
    begin
      hashtag = sanitize_for_hash(params["hashtag"])
      total_tweets = Tweet.where("hashtag = ?", hashtag).count
      total_users = Tweet.where("hashtag = ?", hashtag).select("user_id").map(&:user_id).uniq.count
      user_with_most_tweets = Tweet.find_by_sql("select count(*) as count, user_id from tweets where hashtag = \'#{hashtag}\' group by user_id order by count desc limit 1").first.try(:user).try(:handle)
      success = true
    rescue Exception => e
      puts "ERROR: in updating stats for #{params['hashtag']} with #{e.class}=#{e.message}"
      success = false
    end
    render :json => {:success => success, :hashtag => params["hashtag"], :total_tweets => total_tweets.to_i, :total_users => total_users.to_i, :user_with_most_tweets => user_with_most_tweets.to_s}.to_json
  end

  private

  def sanitize_for_hash(hashtag)
    (hashtag[0]=="#" ? hashtag[1..-1] : hashtag).to_s
  end

  #Reads all previously started and unclosed processes and terminates them
  def cleanup
    process_ids = File.read("#{Rails.root.to_s}/tmp/pids/active_forks.csv").split("\n").map(&:to_i)
    left = []
    if process_ids
      process_ids.each do |id|
        left = kill_process(id, left)
      end
    else
      puts "Could not find processes to kill!"
    end
    File.open("#{Rails.root.to_s}/tmp/pids/active_forks.csv", "w") do |f|
      left.each do |l|
        f.write "#{l}\n"
      end
    end    
  end

  def kill_process(pid, left_pids)
    begin
      puts "KILLING: process with id #{pid}"
      Process.kill 9, pid
    rescue Exception => e
      left_pids << pid
      puts "ERROR: Couldn't kill #{pid}. #{e.class} => #{e.message}"
    end
    return left_pids
  end
end