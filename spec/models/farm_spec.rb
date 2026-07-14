require 'rails_helper'

RSpec.describe Farm, type: :model do
  describe "validações" do
    it "é válida com nome e usuário" do
      expect(build(:farm)).to be_valid
    end

    it "é inválida sem nome" do
      expect(build(:farm, name: nil)).not_to be_valid
    end

    it "é inválida sem usuário" do
      expect(build(:farm, user: nil)).not_to be_valid
    end
  end

  describe "associações" do
    it "pertence a um usuário" do
      user = create(:user)
      farm = create(:farm, user: user)
      expect(farm.user).to eq(user)
    end
  end
end
