require 'rails_helper'

RSpec.describe Field, type: :model do
  describe "validações" do
    it "é válido com nome e fazenda" do
      expect(build(:field)).to be_valid
    end

    it "é inválido sem nome" do
      expect(build(:field, name: nil)).not_to be_valid
    end

    it "é inválido sem fazenda" do
      expect(build(:field, farm: nil)).not_to be_valid
    end
  end

  describe "associações" do
    it "pertence a uma fazenda" do
      farm = create(:farm)
      field = create(:field, farm: farm)
      expect(field.farm).to eq(farm)
    end
  end
end
