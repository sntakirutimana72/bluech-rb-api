module V1
  class InboxController < ApplicationController
    def index
      @previews = Message.inbox(current_user.id)
      as_success(previews: ListSerializer.new(@previews, serializer: InboxSerializer))
    end
  end
end
