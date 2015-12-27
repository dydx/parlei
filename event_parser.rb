require 'nsq'
require_relative './lib/event'
$stdout.sync = true

class AverageLength < Event::Projection
  stream_title 'average'
  filter { ->(data) {
    data.size >= 1 ? data.map { |item| item.length }.reduce(:+) / data.length : data.size }
  }
end

class LastFive < Event::Projection
  stream_title 'last_five'
  filter { ->(data) {
    data.size >= 5 ? data[data.size - 5, data.size] : data }
  }
end

projector = Event::Projector.new(
  Nsq::Producer.new( nsqd: '127.0.0.1:4150', topic: 'logging' ),
  AverageLength.new,
  LastFive.new
)

projector.run
