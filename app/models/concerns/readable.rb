module Readable
  extend ActiveSupport::Concern

  included do
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
