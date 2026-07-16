# Avalia se um valor está dentro da faixa ideal do tipo de sensor.
#
# Retorna um símbolo de status: :ok (dentro da faixa), :low (abaixo do mínimo)
# ou :high (acima do máximo). Para valor nulo (ex: sensor sem leituras no
# período) retorna nil — não há o que alertar.
#
# As faixas são as usadas na simulação (umidade 20–80%, temperatura 10–40 °C,
# pH 4–8) e ficam centralizadas aqui, isoladas da persistência: um valor fora
# da faixa não é inválido, é digno de alerta.
class AlertEvaluator
  IDEAL_RANGES = {
    "humidity" => 20.0..80.0,
    "temperature" => 10.0..40.0,
    "ph" => 4.0..8.0
  }.freeze

  def initialize(sensor_type, value)
    @sensor_type = sensor_type.to_s
    @value = value
  end

  def call
    return nil if value.nil?

    range = IDEAL_RANGES.fetch(sensor_type)
    return :low  if value < range.begin
    return :high if value > range.end

    :ok
  end

  private

  attr_reader :sensor_type, :value
end
