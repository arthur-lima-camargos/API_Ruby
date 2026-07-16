require "rails_helper"

RSpec.describe "Api::V1::Sensors", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:field) { create(:field, farm: create(:farm, user: user)) }

  describe "GET /api/v1/fields/:field_id/sensors" do
    it "lista os sensores do talhão do usuário" do
      meu = create(:sensor, field: field)
      create(:sensor, field: create(:field, farm: create(:farm, user: other_user)))

      get "/api/v1/fields/#{field.id}/sensors", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body["data"].map { |s| s["id"].to_i }
      expect(ids).to contain_exactly(meu.id)
    end

    it "exige autenticação" do
      get "/api/v1/fields/#{field.id}/sensors"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/fields/:field_id/sensors" do
    it "cria um sensor com tipo válido do enum" do
      expect do
        post "/api/v1/fields/#{field.id}/sensors",
             params: { sensor_type: "temperature" }, headers: auth_headers(user)
      end.to change(field.sensors, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig("data", "attributes", "sensor_type")).to eq("temperature")
    end

    it "retorna 422 para sensor_type fora do enum (em vez de 500)" do
      post "/api/v1/fields/#{field.id}/sensors", params: { sensor_type: "radiacao" },
                                                 headers: auth_headers(user)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "não cria sensor em talhão alheio (404)" do
      alheio = create(:field, farm: create(:farm, user: other_user))

      post "/api/v1/fields/#{alheio.id}/sensors", params: { sensor_type: "ph" },
                                                  headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/sensors/:id" do
    it "mostra um sensor do usuário" do
      sensor = create(:sensor, field: field)

      get "/api/v1/sensors/#{sensor.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("data", "attributes", "sensor_type")).to eq(sensor.sensor_type)
    end

    it "retorna 404 para sensor de outro usuário" do
      alheio = create(:sensor, field: create(:field, farm: create(:farm, user: other_user)))

      get "/api/v1/sensors/#{alheio.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v1/sensors/:id" do
    it "atualiza o tipo do sensor" do
      sensor = create(:sensor, field: field, sensor_type: :humidity)

      patch "/api/v1/sensors/#{sensor.id}", params: { sensor_type: "ph" },
                                            headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(sensor.reload.sensor_type).to eq("ph")
    end

    it "retorna 422 ao atualizar para tipo inválido" do
      sensor = create(:sensor, field: field)

      patch "/api/v1/sensors/#{sensor.id}", params: { sensor_type: "invalido" },
                                            headers: auth_headers(user)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /api/v1/sensors/:id" do
    it "remove um sensor do usuário" do
      sensor = create(:sensor, field: field)

      expect do
        delete "/api/v1/sensors/#{sensor.id}", headers: auth_headers(user)
      end.to change(Sensor, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
