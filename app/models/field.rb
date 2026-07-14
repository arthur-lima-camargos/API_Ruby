class Field < ApplicationRecord
  belongs_to :farm

  # Um talhão abriga vários sensores; removê-lo apaga os sensores em cascata.
  has_many :sensors, dependent: :destroy

  validates :name, presence: true
end
