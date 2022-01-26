class Chat < ApplicationRecord
  belongs_to :application, counter_cache: true
  has_many :messages
  attribute :messages_count, :integer, default:0

end
