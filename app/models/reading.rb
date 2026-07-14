class Reading < ApplicationRecord
  belongs_to :sensor

  # Valida apenas coerência do registro (tem valor, tem quando foi medido).
  # A faixa realista por tipo de sensor não é validada aqui: um valor fora da
  # faixa não é inválido, é digno de alerta — regra que vive na camada de alertas.
  validates :value, presence: true
  validates :recorded_at, presence: true
end
