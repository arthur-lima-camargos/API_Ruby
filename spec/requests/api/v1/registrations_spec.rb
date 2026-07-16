require "rails_helper"

RSpec.describe "POST /api/v1/signup", type: :request do
  let(:valid_params) do
    { name: "João Produtor", email: "joao@example.com", password: "password123" }
  end

  context "com dados válidos" do
    it "cria o usuário e retorna um token" do
      expect do
        post "/api/v1/signup", params: valid_params
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["token"]).to be_present
      expect(response.parsed_body.dig("user", "email")).to eq("joao@example.com")
    end

    it "gera um token que decodifica para o usuário criado" do
      post "/api/v1/signup", params: valid_params

      payload = JsonWebToken.decode(response.parsed_body["token"])
      expect(payload[:user_id]).to eq(User.last.id)
    end
  end

  context "com dados inválidos" do
    it "rejeita e-mail com formato inválido (422)" do
      expect do
        post "/api/v1/signup", params: valid_params.merge(email: "invalido")
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "rejeita e-mail duplicado" do
      create(:user, email: "joao@example.com")

      post "/api/v1/signup", params: valid_params
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejeita senha curta" do
      post "/api/v1/signup", params: valid_params.merge(password: "123")
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
