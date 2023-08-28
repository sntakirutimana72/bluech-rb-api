module V1
  class MessagesController < ApplicationController
    include Validatable::Message
    include Parameterizable::Message

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
      options = mark_as_read_params
      options[:ids] = options[:ids].join(',')
      options[:ids] = Message.mark_as_read(options.values).rows.map(&:first)

      ChatsRelayJob.read(options)
      as_success(ids: options[:ids])
    end
  end
end
