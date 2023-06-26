class ChatsRelayJob < ApplicationJob
  queue_as :default

  def perform(resource, payload)
    ChatsQuartersChannel.broadcast_to resource, payload
  end

  def self.relay(resource, message)
    perform_later(resource, MessageSerializer.new(message).as_json)
  end
end
