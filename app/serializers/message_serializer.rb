class MessageSerializer < ActiveModel::Serializer
  attributes :id, :desc, :isEdited, :isSeen, :createdAt, :updatedAt

  belongs_to :author, class_name: 'User', serializer: AuthorSerializer

  def isEdited
    object.is_edited
  end

  def isSeen
    !!object.seen_at
  end

  def createdAt
    object.created_at
  end

  def updatedAt
    object.updated_at
  end
end
