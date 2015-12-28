require 'nsq'
require_relative './lib/event'

logwriter = Event::Writer.new(
  Nsq::Consumer.new(
    nsqlookupd: '127.0.0.1:4161',
    topic: 'parleis',
    channel: 'server-facing'
  )
)

logwriter.run
