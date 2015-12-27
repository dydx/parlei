require 'nsq'
require_relative './lib/event'

class FiveLatestProjection < Event::Projection
  def initialize
    super('127.0.0.1:4150', 'events')
  end

  def run
    previous_push = []
    loop do
      log = File.open('logs/master_audit.log', 'r').to_a
      current_push = (log.size >= 5 ? log[log.size - 5, log.size] : log)
      unless current_push == previous_push
        write(current_push)

        previous_push = current_push
      end
      sleep 2.0
    end
  end
end

# still trying to iron out the details for a second projection stream
# with regard to the message queue and the server sent events
class AverageMessageLength < Event::Projection
  def initialize
    super('127.0.0.1:4150', 'average')
  end

  def run
    previous_push = 0
    loop do
      log = File.open('logs/master_audit.log', 'r').to_a
      current_push = (log.size >= 1 ? log.map { |item| item.length }.reduce(:+) / log.length : log.size)

      unless current_push == previous_push
        write(current_push)
      end

      previous_push = current_push
      sleep 2.0
    end
  end
end

# run each of our projection runners in parallel
projections = []
threads = []

projections << AverageMessageLength.new
projections << FiveLatestProjection.new

for projection in projections
  threads << Thread.new(projection) { |proj|
    proj.run
  }
end

threads.each { |thr| thr.join }
