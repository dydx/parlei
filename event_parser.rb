require 'nsq'
require_relative './lib/event'
$stdout.sync = true

class AverageLength < Event::Projection
  stream_title 'average'
  filter { ->(data) {
    data.length >= 1 ? data.map { |item| item.length }.reduce(:+) / data.length : data.length }
  }
end

class LastFive < Event::Projection
  stream_title 'last_five'
  filter { ->(data) {
    data.length >= 5 ? data[data.length - 5, data.length] : data }
  }
end

class TotalMessages < Event::Projection
  stream_title 'total'
  filter { ->(data) { data.length } }
end

class LongestMessage < Event::Projection
  stream_title 'longest'
  filter { ->(data) { data.max_by { |item| item.length } } }
end

projector = Event::Projector.new(
  Nsq::Producer.new( nsqd: '127.0.0.1:4150', topic: 'logging' ),
  [ AverageLength.new, LastFive.new, TotalMessages.new, LongestMessage.new ]
)

projector.run
