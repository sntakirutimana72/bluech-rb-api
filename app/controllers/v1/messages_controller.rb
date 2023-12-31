module V1
  class MessagesController < ApplicationController
    before_action :validate_convo_parameters, only: :index

    def index
      @meta, @chats = pagy(Message.conversation(convo_params), page: page_num)
      as_success(
        chats: ListSerializer.new(@chats, serializer: MessageSerializer),
        pagination: paginate(@meta)
      )
    end

    def create
      @message = Message.new(create_params)
      return as_unprocessable(error: format_resource_errors(@message)) unless @message.save

      ChatsRelayJob.relay(@message)
      as_created(message: MessageSerializer.new(@message))
    end

    private

    def page_num
      num = params.require(:convo)[:page].to_i
      num.zero? ? 1 : num
    end

    def validate_convo_parameters
      return if params[:convo].is_a?(ActionController::Parameters) && params[:convo][:channelId].to_i.positive?

      as_invalid(error: ':channelId required')
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
