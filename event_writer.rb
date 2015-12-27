require 'nsq'
require './event'

class Auditor < Event::Auditor
  def initialize
    super('127.0.0.1:4161', 'parleis', 'whatever')
  end

  def run
    loop do
      File.open('logs/master_audit.log', 'a') do |log|
        log.puts read
      end
    end
  end
end

auditor = Auditor.new
auditor.run
