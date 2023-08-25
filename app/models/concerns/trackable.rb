module Trackable
  extend ActiveSupport::Concern

  included do
    scope :conversation, lambda { |options|
      where(
        '(author_id = :me AND recipient_id = :channelId) OR (author_id = :channelId AND recipient_id = :me)',
        options
      ).order(:created_at)
    }

    scope :inbox, lambda { |rec_id|
      select(
        :author_id,
        :desc,
        :created_at,
        'COUNT(messages.author_id) unread'
      )
        .joins(
          'LEFT JOIN (select A.author_id from messages A WHERE seen_at IS NULL) AS CX ON CX.author_id = messages.author_id'
        )
        .where(recipient_id: rec_id)
        .where.not(author_id: rec_id)
        .having(
          created_at: self.select('MAX(created_at)').group(:author_id),
          author_id: self.select('author_id').group(:author_id)
        )
        .group(:author_id, :created_at, :desc)
        .order(created_at: :desc)
    }
  end
end
