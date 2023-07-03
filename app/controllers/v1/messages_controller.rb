module V1
  class MessagesController < ApplicationController
    before_action :load_resource

    def index
      @chats = Message.where('author_id = ? or recipient_id = ?', current_user.id)
      as_success(chats: ListSerializer.new(@chats))
    end

    def create
      @message = Message.new(create_params)
      return as_unprocessable(error: format_resource_errors(@message)) unless @message.save

      ChatsJob.relay(@recipient, @message)
      head :created
    end

    private

    def load_resource
      @recipient = User.find_by(id: params[:message][:recipient_id])
    end

    def create_params
      params
        .require(:message)
        .permit(:desc)
        .merge(author: current_user, recipient: @recipient)
    end
  end
end
