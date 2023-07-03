class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  has_many :messages, foreign_key: :author_id
  has_many :inbounds, foreign_key: :recipient_id

  devise :database_authenticatable, :registerable, :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :name, presence: true, length: { minimum: 3, maximum: 24 }
end
