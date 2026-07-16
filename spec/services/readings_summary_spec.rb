require "rails_helper"

RSpec.describe ReadingsSummary do
  let(:sensor) { create(:sensor, sensor_type: :humidity) }

  describe "#call" do
    it "calcula contagem, média, mínimo e máximo do período" do
      create(:reading, sensor: sensor, value: 40, recorded_at: 1.day.ago)
      create(:reading, sensor: sensor, value: 60, recorded_at: 2.days.ago)

      result = described_class.new(sensor, period: "7d").call

      expect(result[:count]).to eq(2)
      expect(result[:average]).to eq(50.0)
      expect(result[:min]).to eq(40.0)
      expect(result[:max]).to eq(60.0)
      expect(result[:period]).to eq("7d")
      expect(result[:sensor_id]).to eq(sensor.id)
    end

    it "ignora leituras fora da janela do período" do
      create(:reading, sensor: sensor, value: 50, recorded_at: 1.day.ago)
      create(:reading, sensor: sensor, value: 99, recorded_at: 10.days.ago)

      result = described_class.new(sensor, period: "7d").call

      expect(result[:count]).to eq(1)
      expect(result[:average]).to eq(50.0)
    end

    it "inclui o alerta calculado sobre a média" do
      create(:reading, sensor: sensor, value: 10, recorded_at: 1.hour.ago) # abaixo de 20

      result = described_class.new(sensor, period: "24h").call

      expect(result[:alert]).to eq(:low)
    end

    it "retorna zeros/nil quando não há leituras no período" do
      result = described_class.new(sensor, period: "7d").call

      expect(result[:count]).to eq(0)
      expect(result[:average]).to be_nil
      expect(result[:min]).to be_nil
      expect(result[:alert]).to be_nil
    end

    it "usa 7d como padrão para período ausente ou desconhecido" do
      expect(described_class.new(sensor).call[:period]).to eq("7d")
      expect(described_class.new(sensor, period: "banana").call[:period]).to eq("7d")
    end
  end
end
