module Api
  module V1
    # Endpoint público de login. Valida as credenciais e devolve um JWT.
    class SessionsController < ApplicationController
      def create
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          render json: { token: token }, status: :ok
        else
          # Mensagem genérica: não revela se o e-mail existe ou se a senha errou.
          render json: { error: "Credenciais inválidas" }, status: :unauthorized
        end
      end
    end
  end
end
