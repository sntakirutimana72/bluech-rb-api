module V1
  class MessagesController < ApplicationController
    def index
      @chats = Message.all_since({ id: current_user.id })
      as_success(chats: ListSerializer.new(@chats))
    end

    def create
      @message = Message.new(create_params)
      return as_unprocessable(error: format_resource_errors(@message)) unless @message.save

      ChatsRelayJob.relay(@message)
      as_created(message: MessageSerializer.new(@message))
    end

    private

    def create_params
      params
        .require(:message)
        .permit(:desc, :recipient_id)
        .merge(author: current_user)
    end
  end
end
