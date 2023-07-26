class Message < ApplicationRecord
  include Trackable

  belongs_to :author, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  validates :desc, presence: true, length: { minimum: 1 }
end
