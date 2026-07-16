require "rails_helper"

RSpec.describe "Api::V1::Sensors summary", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:sensor) { create(:sensor, sensor_type: :humidity, field: create(:field, farm: create(:farm, user: user))) }

  describe "GET /api/v1/sensors/:id/summary" do
    it "retorna médias, extremos e contagem do período" do
      create(:reading, sensor: sensor, value: 40, recorded_at: 1.day.ago)
      create(:reading, sensor: sensor, value: 60, recorded_at: 2.days.ago)

      get "/api/v1/sensors/#{sensor.id}/summary", params: { period: "7d" },
                                                  headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["count"]).to eq(2)
      expect(body["average"]).to eq(50.0)
      expect(body["min"]).to eq(40.0)
      expect(body["max"]).to eq(60.0)
      expect(body["period"]).to eq("7d")
    end

    it "inclui status de alerta (média abaixo da faixa -> low)" do
      create(:reading, sensor: sensor, value: 10, recorded_at: 1.hour.ago)

      get "/api/v1/sensors/#{sensor.id}/summary", params: { period: "24h" },
                                                  headers: auth_headers(user)

      expect(response.parsed_body["alert"]).to eq("low")
    end

    it "usa 7d como período padrão" do
      get "/api/v1/sensors/#{sensor.id}/summary", headers: auth_headers(user)

      expect(response.parsed_body["period"]).to eq("7d")
    end

    it "retorna 404 para sensor de outro usuário" do
      alheio = create(:sensor, field: create(:field, farm: create(:farm, user: other_user)))

      get "/api/v1/sensors/#{alheio.id}/summary", headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end

    it "exige autenticação" do
      get "/api/v1/sensors/#{sensor.id}/summary"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
