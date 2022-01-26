class Message < ApplicationRecord
  belongs_to :chat, counter_cache: true

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def self.search(query, chat_id)
    __elasticsearch__.search(
      {
        query: {
          bool: {
            must: [
              { 
                match: { 
                  chat_id: chat_id 
                } 
              },{ 
                query_string: { 
                  query: query, 
                  fields: ['text'] 
                } 
              }
            ]
          }
        }
      }
    )
  end
end
