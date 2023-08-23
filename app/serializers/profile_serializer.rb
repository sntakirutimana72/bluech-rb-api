class ProfileSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :createdAt, :updatedAt

  def createdAt
    object.created_at
  end

  def updatedAt
    object.updated_at
  end
end
