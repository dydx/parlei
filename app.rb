require 'sinatra'
require 'nsq'

set :public_folder, File.dirname(__FILE__) + '/static'
set :views, File.dirname(__FILE__) + '/views'

get '/' do
  erb :index
end

post '/' do
  # open a connection to NSQ
  producer = Nsq::Producer.new(
    nsqd: '127.0.0.1:4150',
    topic: 'parleis'
  )
  # get the post_text from the POST
  post_text = params[:post_text]
  # write to NSQ and close the connection
  producer.write(post_text)
  producer.terminate
end
