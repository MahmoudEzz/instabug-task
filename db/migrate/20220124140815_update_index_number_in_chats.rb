class UpdateIndexNumberInChats < ActiveRecord::Migration[5.2]
  def change
    remove_index :chats, :number
    add_index :chats, :number
  end
end
