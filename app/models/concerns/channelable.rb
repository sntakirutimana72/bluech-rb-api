module Channelable
  module Remindable
    extend ActiveSupport::Concern

    included do
      scope :since, ->(filters) do
        where('author_id = :id OR recipient_id = :id', filters).order(:created_at)
      end
    end
  end

  module Previewable
    extend ActiveSupport::Concern

    included do
      scope :inbox, ->(filters) do
        where('(author_id = :id OR recipient_id = :id) AND (created_at >= :since)', filters)
          .order(created_at: :desc)
      end
    end
  end
end
