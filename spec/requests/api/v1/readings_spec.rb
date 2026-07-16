require "rails_helper"

RSpec.describe "Api::V1::Readings", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:sensor) { create(:sensor, field: create(:field, farm: create(:farm, user: user))) }

  describe "GET /api/v1/sensors/:sensor_id/readings" do
    it "lista as leituras do sensor em ordem cronológica" do
      antiga = create(:reading, sensor: sensor, value: 30, recorded_at: 3.days.ago)
      recente = create(:reading, sensor: sensor, value: 50, recorded_at: 1.hour.ago)

      get "/api/v1/sensors/#{sensor.id}/readings", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body["data"].map { |r| r["id"].to_i }
      expect(ids).to eq([ antiga.id, recente.id ])
    end

    it "filtra por intervalo de datas (from/to)" do
      create(:reading, sensor: sensor, recorded_at: 10.days.ago)
      dentro = create(:reading, sensor: sensor, recorded_at: 2.days.ago)

      get "/api/v1/sensors/#{sensor.id}/readings",
          params: { from: 5.days.ago.iso8601 }, headers: auth_headers(user)

      ids = response.parsed_body["data"].map { |r| r["id"].to_i }
      expect(ids).to contain_exactly(dentro.id)
    end

    it "pagina os resultados (per_page)" do
      create_list(:reading, 3, sensor: sensor)

      get "/api/v1/sensors/#{sensor.id}/readings",
          params: { per_page: 2 }, headers: auth_headers(user)

      expect(response.parsed_body["data"].size).to eq(2)
    end

    it "retorna 404 para sensor de outro usuário" do
      alheio = create(:sensor, field: create(:field, farm: create(:farm, user: other_user)))

      get "/api/v1/sensors/#{alheio.id}/readings", headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end

    it "exige autenticação" do
      get "/api/v1/sensors/#{sensor.id}/readings"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/sensors/:sensor_id/readings" do
    it "registra uma leitura" do
      expect do
        post "/api/v1/sensors/#{sensor.id}/readings",
             params: { value: 42.5, recorded_at: 1.hour.ago.iso8601 },
             headers: auth_headers(user)
      end.to change(sensor.readings, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "usa o instante atual quando recorded_at é omitido" do
      post "/api/v1/sensors/#{sensor.id}/readings",
           params: { value: 42.5 }, headers: auth_headers(user)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig("data", "attributes", "recorded_at")).to be_present
    end

    it "aceita valor fora da faixa realista (fica a cargo dos alertas)" do
      post "/api/v1/sensors/#{sensor.id}/readings",
           params: { value: 999 }, headers: auth_headers(user)

      expect(response).to have_http_status(:created)
    end

    it "retorna 422 sem value" do
      post "/api/v1/sensors/#{sensor.id}/readings",
           params: { recorded_at: Time.current.iso8601 }, headers: auth_headers(user)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "não registra leitura em sensor de outro usuário (404)" do
      alheio = create(:sensor, field: create(:field, farm: create(:farm, user: other_user)))

      post "/api/v1/sensors/#{alheio.id}/readings",
           params: { value: 42 }, headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end
  end
end
