require "rails_helper"

# Exercita o `before_action :authenticate_request` do BaseController de forma
# isolada, via anonymous controller, antes de existirem endpoints de negócio
# reais (Fase 4). Cobre US-1.3 (acesso autenticado).
RSpec.describe Api::V1::BaseController, type: :controller do
  controller do
    def index
      render json: { user_id: current_user.id }
    end
  end

  before { routes.draw { get "index" => "api/v1/base#index" } }

  let(:user) { create(:user) }

  context "com token válido" do
    it "autentica e expõe o current_user" do
      request.headers["Authorization"] = "Bearer #{JsonWebToken.encode(user_id: user.id)}"

      get :index

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["user_id"]).to eq(user.id)
    end
  end

  context "sem autenticação válida" do
    it "retorna 401 sem header Authorization" do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end

    it "retorna 401 com token malformado" do
      request.headers["Authorization"] = "Bearer token.invalido"
      get :index
      expect(response).to have_http_status(:unauthorized)
    end

    it "retorna 401 com token expirado" do
      request.headers["Authorization"] = "Bearer #{JsonWebToken.encode({ user_id: user.id }, 1.hour.ago)}"
      get :index
      expect(response).to have_http_status(:unauthorized)
    end

    it "retorna 401 quando o usuário do token não existe mais" do
      token = JsonWebToken.encode(user_id: user.id)
      user.destroy
      request.headers["Authorization"] = "Bearer #{token}"

      get :index
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
