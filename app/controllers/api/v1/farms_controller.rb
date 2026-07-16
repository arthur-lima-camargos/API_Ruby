module Api
  module V1
    class FarmsController < BaseController
      before_action :set_farm, only: %i[show update destroy]

      def index
        render json: FarmSerializer.new(current_user.farms).serializable_hash
      end

      def show
        render json: FarmSerializer.new(@farm).serializable_hash
      end

      def create
        farm = current_user.farms.build(farm_params)

        if farm.save
          render json: FarmSerializer.new(farm).serializable_hash, status: :created
        else
          render_errors(farm)
        end
      end

      def update
        if @farm.update(farm_params)
          render json: FarmSerializer.new(@farm).serializable_hash
        else
          render_errors(@farm)
        end
      end

      def destroy
        @farm.destroy
        head :no_content
      end

      private

      # Escopo por usuário: só encontra fazendas do current_user (senão, 404).
      def set_farm
        @farm = current_user.farms.find(params[:id])
      end

      def farm_params
        params.permit(:name, :location)
      end
    end
  end
end
