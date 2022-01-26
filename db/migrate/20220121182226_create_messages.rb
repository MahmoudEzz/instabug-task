class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.references :chat, foreign_key: {on_delete: :cascade}
      t.integer :number
      t.text :text

      t.timestamps
    end
    add_index :messages, :number, unique: true
  end
end
