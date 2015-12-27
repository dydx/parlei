require 'nsq'

consumer = Nsq::Consumer.new(
  nsqlookupd: '127.0.0.1:4161',
  topic: 'average',
  channel: 'average_length'
)

loop do
  if msg = consumer.pop_without_blocking
    message = msg.body
    msg.finish
    puts message
  else
    sleep 1.0
  end
end
