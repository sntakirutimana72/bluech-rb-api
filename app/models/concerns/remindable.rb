module Remindable
  extend ActiveSupport::Concern

  included do
    scope :all_since, ->(filters) do
      where('author_id = :id OR recipient_id = :id', filters).order(:created_at)
    end
  end
end
