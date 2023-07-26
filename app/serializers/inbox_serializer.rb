class InboxSerializer < ActiveModel::Serializer
  attributes :id, :preview, :unread

  def id
    object.author_id
  end

  def preview
    object.desc
  end
end
