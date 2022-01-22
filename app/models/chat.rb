class Chat < ApplicationRecord
  belongs_to :application
  has_many :messages
  attribute :messages_count, :integer, default:0

end
