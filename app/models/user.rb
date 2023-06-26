class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include Searchable

  has_many :memberships
  has_many :messages, foreign_key: :author_id
  has_many :quarters, through: :memberships, source: :channel

  devise :database_authenticatable, :registerable, :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :name, presence: true, length: { minimum: 3, maximum: 24 }
end
