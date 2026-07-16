module Api
  module V1
    # Base dos endpoints de negócio: exige um JWT válido e expõe `current_user`.
    # Controllers públicos (signup/login) NÃO herdam desta classe.
    class BaseController < ApplicationController
      before_action :authenticate_request

      private

      attr_reader :current_user

      # Decodifica o token do header `Authorization: Bearer <token>` e carrega o
      # usuário. Qualquer falha (header ausente, token inválido/expirado ou
      # usuário inexistente) resulta em 401 sem detalhar a causa.
      def authenticate_request
        payload = JsonWebToken.decode(bearer_token)
        @current_user = User.find_by(id: payload[:user_id]) if payload

        render_unauthorized unless @current_user
      end

      def bearer_token
        header = request.headers["Authorization"]
        header&.split(" ")&.last
      end

      def render_unauthorized
        render json: { error: "Não autenticado" }, status: :unauthorized
      end
    end
  end
end
