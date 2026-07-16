class FarmSerializer
  include JSONAPI::Serializer

  attributes :name, :location, :created_at, :updated_at

  has_many :fields
end
