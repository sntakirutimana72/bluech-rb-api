class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :channel, class_name: 'ChatsQuarter'
end
