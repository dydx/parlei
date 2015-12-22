require 'nsq'

events = Nsq::Consumer.new(
  nsqlookupd: '127.0.0.1:4161',
  topic: 'parleis',
  channel: 'raw_events'
)

# this is going to consume events out of NSQ
# and push them to an audit log

loop do
  if msg = events.pop_without_blocking
    puts msg.body
    msg.finish
  else
    sleep 0.1
  end
end
