class Sensor < ApplicationRecord
  belongs_to :field

  # Um sensor gera muitas leituras ao longo do tempo; removê-lo apaga as leituras em cascata.
  has_many :readings, dependent: :destroy

  # sensor_type aceita apenas estes três valores, guardados como string legível
  # no banco. O enum gera helpers (humidity?, temperature!) e escopos (Sensor.ph).
  enum :sensor_type, { humidity: "humidity", temperature: "temperature", ph: "ph" }

  validates :sensor_type, presence: true
end
