# Resume as leituras de um sensor num período: contagem, média, mínimo e máximo,
# mais um status de alerta calculado sobre a média (via AlertEvaluator).
#
# O período aceita "24h", "7d" ou "30d"; valores ausentes ou desconhecidos caem
# no padrão de 7 dias. Os agregados são calculados no banco (AVG/MIN/MAX/COUNT),
# não em Ruby, para não carregar todas as leituras em memória.
class ReadingsSummary
  PERIODS = {
    "24h" => 24.hours,
    "7d" => 7.days,
    "30d" => 30.days
  }.freeze
  DEFAULT_PERIOD = "7d"

  def initialize(sensor, period: DEFAULT_PERIOD)
    @sensor = sensor
    @period = PERIODS.key?(period.to_s) ? period.to_s : DEFAULT_PERIOD
  end

  def call
    average = scope.average(:value)

    {
      sensor_id: sensor.id,
      sensor_type: sensor.sensor_type,
      period: period,
      count: scope.count,
      average: to_number(average),
      min: to_number(scope.minimum(:value)),
      max: to_number(scope.maximum(:value)),
      alert: AlertEvaluator.new(sensor.sensor_type, to_number(average)).call
    }
  end

  private

  attr_reader :sensor, :period

  # Leituras do sensor dentro da janela do período (a partir de agora para trás).
  def scope
    @scope ||= sensor.readings.where(recorded_at: PERIODS.fetch(period).ago..)
  end

  # AVG/MIN/MAX vêm como BigDecimal (ou nil); convertemos para float arredondado
  # para a resposta JSON sair com números legíveis em vez de strings decimais.
  def to_number(value)
    value&.to_f&.round(2)
  end
end
