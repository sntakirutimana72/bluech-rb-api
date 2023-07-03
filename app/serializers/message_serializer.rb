class MessageSerializer < ActiveModel::Serializer
  attributes :id, :desc, :is_edited, :creation_date, :last_update

  belongs_to :author, class_name: 'User', serializer: AuthorSerializer

  def creation_date
    object.created_at
  end

  def last_update
    object.updated_at
  end
end
