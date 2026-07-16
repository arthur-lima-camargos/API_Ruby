require "rails_helper"

RSpec.describe "Api::V1::Farms", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "autenticação" do
    it "exige token válido (401 sem header)" do
      get "/api/v1/farms"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/farms" do
    it "retorna apenas as fazendas do usuário autenticado" do
      minha = create(:farm, user: user)
      create(:farm, user: other_user)

      get "/api/v1/farms", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body["data"].map { |f| f["id"].to_i }
      expect(ids).to contain_exactly(minha.id)
    end
  end

  describe "GET /api/v1/farms/:id" do
    it "mostra uma fazenda do usuário" do
      farm = create(:farm, user: user)

      get "/api/v1/farms/#{farm.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("data", "attributes", "name")).to eq(farm.name)
    end

    it "retorna 404 para fazenda de outro usuário" do
      alheia = create(:farm, user: other_user)

      get "/api/v1/farms/#{alheia.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/farms" do
    it "cria uma fazenda vinculada ao current_user" do
      expect do
        post "/api/v1/farms", params: { name: "Sítio Boa Vista", location: "MG" },
                              headers: auth_headers(user)
      end.to change(user.farms, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig("data", "attributes", "name")).to eq("Sítio Boa Vista")
    end

    it "retorna 422 sem nome" do
      post "/api/v1/farms", params: { location: "MG" }, headers: auth_headers(user)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "PATCH /api/v1/farms/:id" do
    it "atualiza uma fazenda do usuário" do
      farm = create(:farm, user: user)

      patch "/api/v1/farms/#{farm.id}", params: { name: "Novo Nome" },
                                        headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(farm.reload.name).to eq("Novo Nome")
    end

    it "não atualiza fazenda de outro usuário (404)" do
      alheia = create(:farm, user: other_user, name: "Original")

      patch "/api/v1/farms/#{alheia.id}", params: { name: "Invadida" },
                                          headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
      expect(alheia.reload.name).to eq("Original")
    end
  end

  describe "DELETE /api/v1/farms/:id" do
    it "remove uma fazenda do usuário e seus filhos em cascata" do
      farm = create(:farm, user: user)
      field = create(:field, farm: farm)
      create(:sensor, field: field)

      expect do
        delete "/api/v1/farms/#{farm.id}", headers: auth_headers(user)
      end.to change(Farm, :count).by(-1).and change(Field, :count).by(-1).and change(Sensor, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
