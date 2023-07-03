class ChatsQuartersChannel < ApplicationCable::Channel
  def subscribed
    stream_for(current_user)
  end

  def unsubscribed
    stop_all_streams
  end

  def typing(payload)
    ChatsJob.typing(payload, current_user)
  end
end
