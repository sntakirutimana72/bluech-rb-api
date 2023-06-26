class ChatsQuartersChannel < ApplicationCable::Channel
  include Nameable::Peer2PeerNomenclature

  def subscribed
    activate_memberships
  end

  def unsubscribed
    stop_all_streams
  end

  private

  def activate_memberships
    stream_for(current_user)
    current_user.quarters.each { |q| stream_for(q) }
  end
end
