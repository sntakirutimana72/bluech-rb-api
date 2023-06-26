class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :desc, null: false
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :channel, null: false, foreign_key: { to_table: :chats_quarters }
      t.boolean :is_edited, default: false, null: false

      t.timestamps
    end
  end
end
