module Api
  module V1
    # Endpoint público de cadastro. Cria o usuário e já devolve um JWT, para que
    # o cliente saia autenticado sem precisar chamar o login em seguida.
    class RegistrationsController < ApplicationController
      def create
        user = User.new(user_params)

        if user.save
          token = JsonWebToken.encode(user_id: user.id)
          render json: { token: token, user: user_response(user) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def user_params
        params.permit(:name, :email, :password)
      end

      def user_response(user)
        { id: user.id, name: user.name, email: user.email }
      end
    end
  end
end
