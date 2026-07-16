class FieldSerializer
  include JSONAPI::Serializer

  attributes :name, :crop, :created_at, :updated_at

  belongs_to :farm
  has_many :sensors
end
