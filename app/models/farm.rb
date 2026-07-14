class Farm < ApplicationRecord
  belongs_to :user

  # Uma fazenda agrupa vários talhões; removê-la apaga os talhões em cascata.
  has_many :fields, dependent: :destroy

  validates :name, presence: true
end
