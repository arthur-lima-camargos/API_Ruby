module Api
  module V1
    class FieldsController < BaseController
      before_action :set_farm, only: %i[index create]
      before_action :set_field, only: %i[show update destroy]

      def index
        render json: FieldSerializer.new(@farm.fields).serializable_hash
      end

      def show
        render json: FieldSerializer.new(@field).serializable_hash
      end

      def create
        field = @farm.fields.build(field_params)

        if field.save
          render json: FieldSerializer.new(field).serializable_hash, status: :created
        else
          render_errors(field)
        end
      end

      def update
        if @field.update(field_params)
          render json: FieldSerializer.new(@field).serializable_hash
        else
          render_errors(@field)
        end
      end

      def destroy
        @field.destroy
        head :no_content
      end

      private

      # Coleção/criação: aninhadas na fazenda (shallow) e escopadas ao usuário.
      def set_farm
        @farm = current_user.farms.find(params[:farm_id])
      end

      # Ações de membro: id próprio do talhão, escopado pelo usuário via associação.
      def set_field
        @field = current_user.fields.find(params[:id])
      end

      def field_params
        params.permit(:name, :crop)
      end

      def render_errors(record)
        render json: { errors: record.errors.full_messages }, status: :unprocessable_content
      end
    end
  end
end
