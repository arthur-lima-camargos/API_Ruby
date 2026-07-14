class Field < ApplicationRecord
  belongs_to :farm

  validates :name, presence: true
end
