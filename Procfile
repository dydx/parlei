nsqlookupd: nsqlookupd
nsqd: nsqd --lookupd-tcp-address=127.0.0.1:4160
nsqadmin: nsqadmin --lookupd-http-address=127.0.0.1:4161
client: ruby app.rb
event_writer: ruby event_writer.rb
event_parser: ruby event_parser.rb
