class ChatsQuarterUpdaterJob < ApplicationJob
  queue_as :default

  def perform(resource, message)
    ChatsQuartersChannel.broadcast_to resource, message
  end

  def self.notify(resource, user)
    perform_later(user, ChatsQuarterSerializer.new(resource).as_json)
  end
end
