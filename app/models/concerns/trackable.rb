module Trackable
  extend ActiveSupport::Concern

  included do
    scope :conversation, lambda { |options|
      where(
        '(author_id = :me AND recipient_id = :channelId) OR (author_id = :channelId AND recipient_id = :me)',
        options
      ).order(:created_at)
    }

    scope :inbox, lambda { |recipient_id|
      select(
        :author_id,
        :desc,
        :created_at,
        'COUNT(messages.author_id) unread'
      ).joins(
        "INNER JOIN (select m1.author_id from messages m1 WHERE seen_at IS NULL AND recipient_id = #{recipient_id} AND author_id != #{recipient_id}) AS m1x ON m1x.author_id = messages.author_id"
      ).where(
        recipient_id:
      ).having(
        created_at: self.select('MAX(created_at)').where(recipient_id:, seen_at: nil).group(:author_id),
        author_id: self.select('author_id').group(:author_id)
      ).group(
        :author_id, :created_at, :desc
      ).order(
        created_at: :desc
      )
    }

    scope :mark_as_read, ->(binds) do
      connection.exec_query(
        "UPDATE messages SET seen_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE id = ANY(STRING_TO_ARRAY($1, ',')::INT[]) AND seen_at IS NULL AND author_id = $2 AND recipient_id = $3 RETURNING id;",
        'MARK_SEEN',
        binds,
        prepare: true
      )
    end

    scope :mark_all_as_read, ->(binds) do
      connection.exec_query(
        "UPDATE messages SET seen_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP WHERE seen_at IS NULL AND author_id = $1 AND recipient_id = $2 RETURNING id;",
        'MARK_SEEN',
        binds,
        prepare: true
      )
    end
  end
end
