class ChatsQuarter < ApplicationRecord
  has_many :chats, class_name: 'Message', foreign_key: :channel_id
  has_many :memberships, foreign_key: :channel_id
  has_many :members, through: :memberships, source: :user

  def member?(user)
    user.is_a?(Integer) ? members.ids.include?(user) : members.include?(user)
  end
end
