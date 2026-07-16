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

  describe "associações" do
    it "tem muitas fazendas" do
      user = create(:user)
      create(:farm, user: user)
      create(:farm, user: user)
      expect(user.farms.count).to eq(2)
    end

    it "remove as fazendas em cascata ao ser destruído" do
      user = create(:user)
      create(:farm, user: user)
      expect { user.destroy }.to change(Farm, :count).by(-1)
    end

    it "acessa os talhões através das fazendas (has_many :through)" do
      user = create(:user)
      field = create(:field, farm: create(:farm, user: user))
      create(:field, farm: create(:farm)) # de outro usuário

      expect(user.fields).to contain_exactly(field)
    end

    it "acessa os sensores através dos talhões (has_many :through)" do
      user = create(:user)
      sensor = create(:sensor, field: create(:field, farm: create(:farm, user: user)))
      create(:sensor, field: create(:field, farm: create(:farm))) # de outro usuário

      expect(user.sensors).to contain_exactly(sensor)
    end
  end
end
