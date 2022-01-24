class MessageJob
  include Sidekiq::Job

  def perform(message)
    message = Message.new(message)
    if message.save
      puts "Message created successfully"
    end
  end
end
