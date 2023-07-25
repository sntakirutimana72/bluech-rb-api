class PeopleSerializer < ActiveModel::Serializer
  attributes :id, :name, :bio

  def bio
    "Hey there! I'm using bluech"
  end
end
