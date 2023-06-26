class Message < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :channel, class_name: 'ChatsQuarter'

  validates :desc, presence: true, length: { minimum: 1 }
  validate :membership_required

  private

  def membership_required
    errors.add(:channel_id, 'Must have membership') unless !channel.nil? && channel.member?(author)
  end
end
