require "rails_helper"

RSpec.describe "POST /api/v1/login", type: :request do
  let!(:user) { create(:user, email: "joao@example.com", password: "password123") }

  context "com credenciais válidas" do
    it "retorna um token" do
      post "/api/v1/login", params: { email: "joao@example.com", password: "password123" }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["token"]).to be_present
    end
  end

  context "com credenciais inválidas" do
    it "retorna 401 quando a senha está errada" do
      post "/api/v1/login", params: { email: "joao@example.com", password: "errada" }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).not_to have_key("token")
    end

    it "retorna 401 quando o e-mail não existe" do
      post "/api/v1/login", params: { email: "naoexiste@example.com", password: "password123" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
