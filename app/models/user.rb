class User < ApplicationRecord
  has_many :outbounds,
           class_name: 'Message',
           foreign_key: 'sender_id'

  has_many :inbounds,
           class_name: 'Message',
           foreign_key: 'recipient_id'

  validates :name, presence: true, length: { minimum: 3, maximum: 24 }
end
