require 'nsq'

events = Nsq::Consumer.new(
  nsqlookupd: '127.0.0.1:4161',
  topic: 'parleis',
  channel: 'raw_events'
)

loop do
  if msg = events.pop_without_blocking
    puts msg.body
    # need to write this message to a file
    File.open('logs/master_audit.log', 'a') do |log|
      log.puts msg.body
    end

    msg.finish
  else
    sleep 0.1
  end
end
