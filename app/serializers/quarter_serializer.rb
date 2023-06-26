class QuarterSerializer < ActiveModel::Serializer
  attribute :id
  attribute :name, unless: -> { object.name.nil? }
end
