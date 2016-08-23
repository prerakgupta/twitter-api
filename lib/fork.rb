include TwitterStreaming::Api

begin
  hashtag = ARGV[0]
  if hashtag
    pid = fork do
      start_streaming(hashtag)
    end
    Process.detach(pid)
    puts "Started new process with id #{pid} for hashtag ##{hashtag}"
    File.open("#{Rails.root.to_s}/tmp/pids/active_forks.csv", "a") do |f|
      f.write "#{pid}\n"
    end
    exit 0
  else
    puts "ERROR: No hashtag found!"
    exit 1
  end
rescue => ex
  puts "ERROR: in starting the process #{ex.class}=#{ex.message}"
  exit 1
end