class SensorSerializer
  include JSONAPI::Serializer

  attributes :sensor_type, :created_at, :updated_at

  belongs_to :field
end
