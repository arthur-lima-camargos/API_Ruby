require "rails_helper"

RSpec.describe AlertEvaluator do
  def status_for(type, value)
    described_class.new(type, value).call
  end

  describe "umidade (faixa 20–80)" do
    it { expect(status_for("humidity", 50)).to eq(:ok) }
    it { expect(status_for("humidity", 10)).to eq(:low) }
    it { expect(status_for("humidity", 95)).to eq(:high) }

    it "trata os limites como dentro da faixa" do
      expect(status_for("humidity", 20)).to eq(:ok)
      expect(status_for("humidity", 80)).to eq(:ok)
    end
  end

  describe "temperatura (faixa 10–40)" do
    it { expect(status_for("temperature", 25)).to eq(:ok) }
    it { expect(status_for("temperature", 5)).to eq(:low) }
    it { expect(status_for("temperature", 45)).to eq(:high) }
  end

  describe "pH (faixa 4–8)" do
    it { expect(status_for("ph", 6)).to eq(:ok) }
    it { expect(status_for("ph", 3)).to eq(:low) }
    it { expect(status_for("ph", 9)).to eq(:high) }
  end

  it "retorna nil quando não há valor (sem leituras)" do
    expect(status_for("humidity", nil)).to be_nil
  end
end
