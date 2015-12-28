require 'nsq'
require 'json'
require './lib/event'
$stdout.sync = true

aggregate = Event::Aggregate.new(
  'total',
  'last_five',
  'longest',
  'average'
)

loop do
  aggt = aggregate.collect
  puts aggt.to_json
  sleep 10.0
end
