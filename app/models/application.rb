class Application < ApplicationRecord
    has_many :applications
    has_secure_token :token
    attribute :chats_count, :integer, default:0
end
