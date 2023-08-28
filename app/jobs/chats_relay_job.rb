class ChatsRelayJob < ApplicationJob
  queue_as :default

  def perform(channel, message)
    ChatsChannel.broadcast_to(channel, message)
  end

  def self.relay(resource)
    perform_later(
      resource.recipient,
      { type: 'message', message: MessageSerializer.new(resource).as_json }
    )
  end

  def self.read(channel_id, reader_id, ids = [])
    return unless ids.length.positive?

    channel = User.find(channel_id)

    set(priority: 75).perform_later(channel, { type: 'read', readerId: reader_id, ids: })
  end

  def self.typing(msg, user)
    channel = User.find_by(id: msg.delete('channelId'))
    return if channel.nil?

    type = msg.delete('action')

    set(priority: 75, queue: :typing_jobs)
      .perform_later(channel, { **msg, type:, author: AuthorSerializer.new(user).as_json })
  end
end
