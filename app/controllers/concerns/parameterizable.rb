module Parameterizable
  module Message
    extend ActiveSupport::Concern

    private

    def mark_as_read_params
      params
        .require(:convo)
        .permit(ids: [])
        .merge(author_id: params.dig(:convo, :authorId), recipient_id: current_user.id)
    end

    def mark_all_as_read_params
      { author_id: params.dig(:convo, :authorId), recipient_id: current_user.id }
    end

    def page_num
      num = params.require(:convo)[:page].to_i
      num.zero? ? 1 : num
    end

    def convo_params
      params
        .require(:convo)
        .permit(:channelId)
        .merge(me: current_user.id).to_h
    end

    def create_params
      params
        .require(:message)
        .permit(:desc, :recipient_id)
        .merge(author: current_user)
    end
  end
end
