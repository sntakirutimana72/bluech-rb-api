module V1
  class MessagesController < ApplicationController
    before_action :load_resource

    def index
      as_success(
        chats: ChatsSerializer.new(@quarter.chats, each_serializer: MessageSerializer)
      )
    end

    def create
      @message = Message.new(create_params)
      return as_unprocessable(errors: @message.errors) unless @message.save

      ChatsRelayJob.relay(@quarter, @message)
      head :created
    end

    private

    def load_resource
      @quarter = ChatsQuarter.find_by(id: params[:chats_quarter_id])
      if @quarter.nil?
        as_unavailable(
          message: "Resource with :chats_quarter_id => #{params[:chats_quarter_id]} not found"
        )
      elsif !@quarter.member?(current_user)
        as_unauthorized(message: 'Not authorized to access resource')
      end
    end

    def create_params
      params
        .require(:message)
        .permit(:desc)
        .merge(author: current_user, channel: @quarter)
    end
  end
end
