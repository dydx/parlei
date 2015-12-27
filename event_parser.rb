require 'nsq'

# open a write connection
producer = Nsq::Producer.new(
  nsqd: '127.0.0.1:4150',
  topic: 'events'
)

previous_push = []
loop do
  log = File.open('logs/master_audit.log', 'r').to_a
  current_push = log[log.size - 5, log.size]

  unless current_push == previous_push
    puts "new data to push!"
    producer.write(current_push)
    previous_push = current_push
  end

  sleep 2.0
end
