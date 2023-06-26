class MessageSerializer < ActiveModel::Serializer
  attributes :id, :desc, :is_edited, :creation_date

  belongs_to :author, class_name: 'User', serializer: AuthorSerializer
  belongs_to :channel, class_name: 'ChatsQuarter', serializer: QuarterSerializer

  def creation_date
    object.created_at
  end
end
