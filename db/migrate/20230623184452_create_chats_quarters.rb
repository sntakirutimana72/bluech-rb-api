class CreateChatsQuarters < ActiveRecord::Migration[7.0]
  def change
    create_table :chats_quarters do |t|
      t.boolean :is_private, default: true, null: false
      t.string :name

      t.timestamps
    end
  end
end
