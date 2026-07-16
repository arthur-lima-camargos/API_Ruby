# Cenário de simulação para exercitar a API sem hardware (US-7.1).
#
# Idempotente: recria a conta demo do zero a cada execução. Removemos o usuário
# demo (o dependent: :destroy limpa fazendas -> talhões -> sensores -> leituras
# em cascata) e reconstruímos tudo. Só a conta demo é tocada — dados reais de
# outros usuários ficam intactos. `srand` fixa a aleatoriedade para que rodar
# `rails db:seed` de novo produza sempre o mesmo dataset.

srand(42)

DEMO_EMAIL = "demo@fazenda.com".freeze
DEMO_PASSWORD = "password123".freeze
HISTORY_DAYS = 30
READING_INTERVAL = 6.hours

# Estrutura: fazenda => { location, fields: { nome_talhão => cultura } }.
# Cada talhão recebe um sensor de cada tipo (humidity, temperature, ph).
FARMS = {
  "Fazenda Boa Vista" => {
    location: "Uberlândia, MG",
    fields: { "Talhão Norte" => "Soja", "Talhão Sul" => "Milho" }
  },
  "Fazenda Santa Clara" => {
    location: "Rio Verde, GO",
    fields: { "Talhão Leste" => "Café", "Talhão Oeste" => "Cana" }
  }
}.freeze

# Gera um valor plausível para o tipo de sensor. `bias` desloca a série toda
# para fora da faixa ideal (para demonstrar alertas): :low abaixo do mínimo,
# :high acima do máximo, nil dentro da faixa. As faixas vêm do AlertEvaluator,
# mantendo uma única fonte de verdade.
def reading_value(sensor_type, bias)
  range = AlertEvaluator::IDEAL_RANGES.fetch(sensor_type)
  span = range.end - range.begin

  value =
    case bias
    when :low  then range.begin - (span * rand(0.05..0.20))
    when :high then range.end + (span * rand(0.05..0.20))
    else rand(range.begin..range.end)
    end

  value.round(2)
end

puts "Limpando conta demo anterior (se existir)..."
User.find_by(email: DEMO_EMAIL)&.destroy

puts "Criando usuário demo (#{DEMO_EMAIL})..."
user = User.create!(name: "Produtor Demo", email: DEMO_EMAIL, password: DEMO_PASSWORD)

sensors = []
FARMS.each do |farm_name, farm_attrs|
  farm = user.farms.create!(name: farm_name, location: farm_attrs[:location])

  farm_attrs[:fields].each do |field_name, crop|
    field = farm.fields.create!(name: field_name, crop: crop)

    Sensor.sensor_types.each_key do |type|
      sensors << field.sensors.create!(sensor_type: type)
    end
  end
end
puts "Estrutura: #{user.farms.count} fazendas, " \
     "#{Field.where(farm: user.farms).count} talhões, #{sensors.size} sensores."

# Enviesa dois sensores para fora da faixa: uma umidade baixa e uma temperatura
# alta — assim o /summary demonstra alertas :low e :high.
biases = Hash.new(nil)
biases[sensors.find(&:humidity?).id] = :low
biases[sensors.find(&:temperature?).id] = :high

# Série temporal: uma leitura a cada READING_INTERVAL nos últimos HISTORY_DAYS.
now = Time.current
timestamps = []
instant = HISTORY_DAYS.days.ago
while instant <= now
  timestamps << instant
  instant += READING_INTERVAL
end

rows = sensors.flat_map do |sensor|
  timestamps.map do |recorded_at|
    {
      sensor_id: sensor.id,
      value: reading_value(sensor.sensor_type, biases[sensor.id]),
      recorded_at: recorded_at,
      created_at: now,
      updated_at: now
    }
  end
end

# insert_all: grava as ~milhares de leituras em um único INSERT, sem instanciar
# um model por linha (bem mais rápido que create! num loop).
Reading.insert_all(rows)
puts "Leituras: #{rows.size} (#{timestamps.size} por sensor)."

low = Sensor.find(biases.key(:low))
high = Sensor.find(biases.key(:high))
puts ""
puts "Pronto! Credenciais demo: #{DEMO_EMAIL} / #{DEMO_PASSWORD}"
puts "Alertas de exemplo no /summary:"
puts "  sensor ##{low.id} (#{low.sensor_type}) -> deve alertar 'low'"
puts "  sensor ##{high.id} (#{high.sensor_type}) -> deve alertar 'high'"
