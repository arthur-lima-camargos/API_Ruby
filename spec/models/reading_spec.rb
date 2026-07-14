require 'rails_helper'

RSpec.describe Reading, type: :model do
  describe "validações" do
    it "é válida com valor, instante e sensor" do
      expect(build(:reading)).to be_valid
    end

    it "é inválida sem valor" do
      expect(build(:reading, value: nil)).not_to be_valid
    end

    it "é inválida sem recorded_at" do
      expect(build(:reading, recorded_at: nil)).not_to be_valid
    end

    it "é inválida sem sensor" do
      expect(build(:reading, sensor: nil)).not_to be_valid
    end

    it "aceita valor fora da faixa realista (fica a cargo dos alertas, não da validação)" do
      expect(build(:reading, value: 200)).to be_valid
    end
  end

  describe "associações" do
    it "pertence a um sensor" do
      sensor = create(:sensor)
      reading = create(:reading, sensor: sensor)
      expect(reading.sensor).to eq(sensor)
    end

    it "é removida em cascata quando o sensor é destruído" do
      reading = create(:reading)
      expect { reading.sensor.destroy }.to change(Reading, :count).by(-1)
    end
  end
end
