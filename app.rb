require 'sinatra'
require 'tilt/erb'
require 'nsq'

set :public_folder, File.dirname(__FILE__) + '/static'
set :views, File.dirname(__FILE__) + '/views'

connections = {}

get '/' do
  erb :index
end

post '/' do
  post_text = params[:post_text]

  producer = Nsq::Producer.new(
    nsqd: '127.0.0.1:4150',
    topic: 'parleis'
  )

  producer.write(post_text)
  producer.terminate

  200
end

get '/events/:stream', provides: 'text/event-stream' do
  if !connections.include? params[:stream]
    connections[params[:stream]] = []
  end

  consumer = Nsq::Consumer.new(
    nsqlookupd: '127.0.0.1:4161',
    topic: params[:stream],
    channel: 'client-facing'
  )


  stream :keep_on do |out|
    connections[params[:stream]] << out
    loop do
      if msg = consumer.pop_without_blocking
        message = msg.body
        msg.finish
        connections[params[:stream]].each { |out| out << "data: #{message}\n\n" }
      else
        sleep 0.1
      end
    end
    out.callback { connections[params[:stream]].delete(out) }
  end
end
