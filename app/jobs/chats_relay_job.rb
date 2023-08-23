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

  def self.typing(msg, user)
    return unless (channel = User.find(msg.delete('channelId')))

    type = msg.delete('action')

    set(priority: 75, queue: :typing_jobs)
      .perform_later(channel, { **msg, type:, author: AuthorSerializer.new(user).as_json })
  end
end
