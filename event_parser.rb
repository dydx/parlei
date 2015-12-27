require 'nsq'
require './event'

class FiveLatestProjection < Event::Projection
  # There should be a more elegant way to handle this, but so far so good?
  def initialize
    super('127.0.0.1:4150', 'events')
  end

  def run
    previous_push = []
    loop do
      # I'd like to keep this information somewhere else
      # and make it a tad more agnostic about where the data
      # itself comes from. Right now this is very FS specific
      log = File.open('logs/master_audit.log', 'r').to_a
      current_push = (log.size >= 5 ? log[log.size - 5, log.size] : log)
      # current_push = Hash[raw_data.each_with_index.map { |val, index| [index, val] } ]
      # current_push = log[log.size - 5, log.size]

      unless current_push == previous_push
        # this is where content is written to the queue
        write(current_push)

        # this prevents us from overloading the channel with old data
        previous_push = current_push
      end
      sleep 2.0
    end
  end
end

projection = FiveLatestProjection.new
projection.run


