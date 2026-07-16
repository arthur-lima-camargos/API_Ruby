class ReadingSerializer
  include JSONAPI::Serializer

  attributes :value, :recorded_at, :created_at

  belongs_to :sensor
end
