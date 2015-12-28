module Event

  class Aggregate
    def initialize(*topics)
      @topics = topics
      @aggregate = {}
    end

    def collect
      for topic in @topics
        # I hate this
        puts "Connecting to NSQ##{topic}..."
        connection = Nsq::Consumer.new(
          nsqlookupd: '127.0.0.1:4161',
          topic: topic,
          channel: "#{topic}_aggregate"
        )

        if msg = connection.pop
          message = msg.body
          msg.finish
          @aggregate[topic] = message
          puts "Got message #{message}..."
          connection.terminate
        end
      end

      # pipe this out
      @aggregate.to_json
    end
  end

  class Projection
    def self.stream_title(name)
      define_method(:stream_title) do
        instance_variable_set(:@stream_title, name)
      end
    end

    def self.filter(&block)
      define_method(:run) do
        self.instance_eval(&block).call(
          # Still need a way to abstract this nonsense away
          # Could this be stored / served via a repository?
          File.open('logs/master_audit.log', 'r').to_a
        )
      end
    end
  end

  class Projector
    def initialize(connection, projections)
      @projections = projections
      @connection = connection
    end

    def write(topic, message)
      @connection.write_to_topic(topic, message)
    end

    def run
      loop do
        for projection in @projections
          name = projection.stream_title
          output = projection.run
          write(name, output)
        end
        sleep 1.0
      end
    end
  end

  class Writer
    def initialize(connection)
      @connection = connection
    end

    # read messages from the queue
    def message_from_queue
      if msg = @connection.pop
        message = msg.body.delete("\n")
        msg.finish
        message
      end
    end

    # write the recieved messages to disc
    def run
      loop do
        File.open('logs/master_audit.log', 'a') do |log|
          log.puts message_from_queue
        end
        sleep 1.0
      end
    end
  end
end
