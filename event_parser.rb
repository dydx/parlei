require 'listen'
require 'nsq'

listener = Listen.to('logs') do |modified, added, removed|
  # get the file that was modified (our audit log)
  file = modified.first
  # get the last line of that file (this is hackish as fuck)
  lines = File.open(file).to_a
  # open a connection to NSQ
  producer = Nsq::Producer.new(
    nsqd: '127.0.0.1:4150',
    topic: 'events'
  )
  # write the changes to NSQ
  producer.write(lines)
  # close NSQ connection
  producer.terminate
end

listener.start # non-blocking!
sleep
