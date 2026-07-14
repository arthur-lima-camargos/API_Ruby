require 'rails_helper'

RSpec.describe Sensor, type: :model do
  describe "validações" do
    it "é válido com tipo e talhão" do
      expect(build(:sensor)).to be_valid
    end

    it "é inválido sem tipo" do
      expect(build(:sensor, sensor_type: nil)).not_to be_valid
    end

    it "é inválido sem talhão" do
      expect(build(:sensor, field: nil)).not_to be_valid
    end

    it "rejeita um tipo fora do enum" do
      expect { build(:sensor, sensor_type: "invalido") }.to raise_error(ArgumentError)
    end
  end

  describe "enum sensor_type" do
    it "expõe métodos de pergunta por tipo" do
      sensor = build(:sensor, sensor_type: :humidity)
      expect(sensor.humidity?).to be(true)
      expect(sensor.temperature?).to be(false)
    end

    it "oferece escopos de consulta por tipo" do
      humidity = create(:sensor, sensor_type: :humidity)
      create(:sensor, sensor_type: :ph)
      expect(Sensor.humidity).to contain_exactly(humidity)
    end
  end

  describe "associações" do
    it "pertence a um talhão" do
      field = create(:field)
      sensor = create(:sensor, field: field)
      expect(sensor.field).to eq(field)
    end
  end
end
