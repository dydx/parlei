module Event

  # this feels pretty good
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
          File.open('logs/master_audit.log', 'r').to_a
        )
      end
    end
  end

  class Projector
    # dependency inject an NSQ connection, as well as our Projections
    def initialize(connection, *projections)
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
        sleep 2.0
      end
    end
  end

  # this, though, still needs a lot of work
  class Auditor
    def initialize(uri, topic, channel)
      @connection = Nsq::Consumer.new( nsqlookupd: uri, topic: topic, channel: channel )
    end

    def read
      if msg = @connection.pop
        message = msg.body
        msg.finish
        message.delete("\n")
      else
        "waiting"
      end
    end

  end
end
