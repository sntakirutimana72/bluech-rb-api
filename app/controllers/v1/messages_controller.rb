module V1
  class MessagesController < ApplicationController
    before_action :validate_convo_params, only: :index
    before_action :validate_seen_params, only: :mark_as_read

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

    def mark_as_read
      args = read_params.values

      if args.first.length
        args[0] = args.first.join(',')
        ids = Message.mark_as_read(args)
      else
        ids = Message.mark_all_as_read(args[1..])
      end

      ChatsRelayJob.seen(*args[1..], ids)
      as_success(ids:)
    end

    private

    def mark_as_read_params
      params
        .require(:convo)
        .permit(ids: [], author_id: nil)
        .merge(recipient_id: current_user.id)
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

    def validate_convo_params
      return if permittable?(:convo) && params[:convo][:channelId].to_i.positive?

      as_invalid(error: ':channelId is required')
    end

    def validate_seen_params
      return if permittable?(:convo) && params[:convo][:author_id].to_i.positive?

      as_invalid(error: ':author_id is required')
    end

    def permittable?(key)
      params[key].is_a?(ActionController::Parameters)
    end
  end
end
