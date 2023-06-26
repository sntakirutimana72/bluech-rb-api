class CreateMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :channel, null: false, foreign_key: { to_table: :chats_quarters }

      t.timestamps
    end
  end
end
