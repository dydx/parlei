require 'nsq'

events = Nsq::Consumer.new(
  nsqlookupd: '127.0.0.1:4161',
  topic: 'parleis',
  channel: 'whatever'
)

loop do
  if msg = events.pop_without_blocking
    File.open('logs/master_audit.log', 'a') do |log|
      puts "Writing new event to audit log"
      log.puts msg.body
    end

    msg.finish
  else
    sleep 0.1
  end
end
