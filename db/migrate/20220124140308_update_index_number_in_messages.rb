class UpdateIndexNumberInMessages < ActiveRecord::Migration[5.2]
  def change
    remove_index :messages, :number
    add_index :messages, :number
  end
end
