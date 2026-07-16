require "rails_helper"

RSpec.describe "Api::V1::Fields", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:farm) { create(:farm, user: user) }

  describe "GET /api/v1/farms/:farm_id/fields" do
    it "lista os talhões da fazenda do usuário" do
      meu = create(:field, farm: farm)
      create(:field, farm: create(:farm, user: other_user))

      get "/api/v1/farms/#{farm.id}/fields", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body["data"].map { |f| f["id"].to_i }
      expect(ids).to contain_exactly(meu.id)
    end

    it "retorna 404 ao listar talhões de fazenda alheia" do
      alheia = create(:farm, user: other_user)

      get "/api/v1/farms/#{alheia.id}/fields", headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end

    it "exige autenticação" do
      get "/api/v1/farms/#{farm.id}/fields"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/farms/:farm_id/fields" do
    it "cria um talhão na fazenda do usuário" do
      expect do
        post "/api/v1/farms/#{farm.id}/fields",
             params: { name: "Talhão Norte", crop: "Soja" }, headers: auth_headers(user)
      end.to change(farm.fields, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig("data", "attributes", "crop")).to eq("Soja")
    end

    it "retorna 422 sem nome" do
      post "/api/v1/farms/#{farm.id}/fields", params: { crop: "Soja" },
                                              headers: auth_headers(user)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "não cria talhão em fazenda alheia (404)" do
      alheia = create(:farm, user: other_user)

      post "/api/v1/farms/#{alheia.id}/fields", params: { name: "X" },
                                                headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/fields/:id" do
    it "mostra um talhão do usuário" do
      field = create(:field, farm: farm)

      get "/api/v1/fields/#{field.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("data", "attributes", "name")).to eq(field.name)
    end

    it "retorna 404 para talhão de outro usuário" do
      alheio = create(:field, farm: create(:farm, user: other_user))

      get "/api/v1/fields/#{alheio.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v1/fields/:id" do
    it "atualiza um talhão do usuário" do
      field = create(:field, farm: farm)

      patch "/api/v1/fields/#{field.id}", params: { crop: "Milho" },
                                          headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(field.reload.crop).to eq("Milho")
    end
  end

  describe "DELETE /api/v1/fields/:id" do
    it "remove um talhão do usuário" do
      field = create(:field, farm: farm)

      expect do
        delete "/api/v1/fields/#{field.id}", headers: auth_headers(user)
      end.to change(Field, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
