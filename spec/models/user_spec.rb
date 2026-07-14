require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validações" do
    it "é válido com nome, e-mail e senha" do
      expect(build(:user)).to be_valid
    end

    it "é inválido sem nome" do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "é inválido sem e-mail" do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it "é inválido com e-mail em formato incorreto" do
      expect(build(:user, email: "nao-e-email")).not_to be_valid
    end

    it "é inválido com e-mail duplicado, ignorando maiúsculas" do
      create(:user, email: "produtor@fazenda.com")
      duplicado = build(:user, email: "PRODUTOR@FAZENDA.COM")
      expect(duplicado).not_to be_valid
    end

    it "é inválido com senha menor que 8 caracteres" do
      expect(build(:user, password: "123")).not_to be_valid
    end
  end

  describe "senha segura (has_secure_password)" do
    it "não armazena a senha em texto puro" do
      user = create(:user, password: "supersecret")
      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq("supersecret")
    end

    it "autentica com a senha correta e rejeita a errada" do
      user = create(:user, password: "supersecret")
      expect(user.authenticate("supersecret")).to eq(user)
      expect(user.authenticate("errada")).to be_falsey
    end
  end
end
