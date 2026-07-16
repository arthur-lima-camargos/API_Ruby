require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode / .decode" do
    it "faz o round-trip do payload" do
      token = described_class.encode(user_id: 42)
      expect(described_class.decode(token)[:user_id]).to eq(42)
    end

    it "adiciona a expiração ao payload" do
      token = described_class.encode(user_id: 1)
      expect(described_class.decode(token)[:exp]).to be_present
    end
  end

  describe ".decode" do
    it "retorna nil para token nulo" do
      expect(described_class.decode(nil)).to be_nil
    end

    it "retorna nil para token malformado" do
      expect(described_class.decode("nao.e.um.token")).to be_nil
    end

    it "retorna nil para token expirado" do
      token = described_class.encode({ user_id: 1 }, 1.hour.ago)
      expect(described_class.decode(token)).to be_nil
    end

    it "retorna nil para token assinado com outra chave" do
      forjado = JWT.encode({ user_id: 1 }, "outra-chave-secreta", "HS256")
      expect(described_class.decode(forjado)).to be_nil
    end
  end
end
