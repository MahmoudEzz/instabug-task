class ChatJob
  include Sidekiq::Job

  def perform(application_id, number)
    new_chat = {
      application_id: application_id,
      number: number
    }
    chat = Chat.new(new_chat)
    if chat.save
      puts "Chat created successfully"
    end
  end
end
