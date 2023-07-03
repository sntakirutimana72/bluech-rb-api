class ChatsJob < ApplicationJob
  queue_as :default

  def perform(channel, message)
    ChatsQuartersChannel.broadcast_to channel, message
  end

  def self.relay(channel, resource)
    perform_later(channel, MessageSerializer.new(resource).as_json)
  end

  def self.typing(message, user)
    id = message.delete(:channel)
    if (channel = User.find_by(id:))
      perform_later(channel, { **message, author: AuthorSerializer.new(user).as_json })
    end
  end
end
