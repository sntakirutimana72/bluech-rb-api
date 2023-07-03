class MessageSerializer < ActiveModel::Serializer
  attributes :id, :desc, :is_edited, :creation_date

  belongs_to :author, class_name: 'User', serializer: AuthorSerializer

  def creation_date
    object.created_at
  end
end
