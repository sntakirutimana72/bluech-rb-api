class AddChannelRecapsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :connected_at, :timestamp
    add_column :users, :disconnected_at, :timestamp
    add_column :users, :online, :boolean, default: false, null: false
  end
end
