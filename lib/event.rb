module Event
  class Projection
    def initialize(uri, topic)
      @connection = Nsq::Producer.new( nsqd: uri, topic: topic )
    end

    def write(message)
      @connection.write(message)
    end
  end

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
