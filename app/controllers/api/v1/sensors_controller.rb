module Api
  module V1
    class SensorsController < BaseController
      before_action :set_field, only: %i[index create]
      before_action :set_sensor, only: %i[show update destroy summary]

      def index
        render json: SensorSerializer.new(@field.sensors).serializable_hash
      end

      # Médias/mín/máx + alerta do sensor no período (?period=24h|7d|30d).
      # O hash de resposta é montado no service object, não aqui.
      def summary
        render json: ReadingsSummary.new(@sensor, period: params[:period]).call
      end

      def show
        render json: SensorSerializer.new(@sensor).serializable_hash
      end

      def create
        sensor = @field.sensors.build(sensor_params)

        if sensor.save
          render json: SensorSerializer.new(sensor).serializable_hash, status: :created
        else
          render_errors(sensor)
        end
      rescue ArgumentError
        render_invalid_type
      end

      def update
        if @sensor.update(sensor_params)
          render json: SensorSerializer.new(@sensor).serializable_hash
        else
          render_errors(@sensor)
        end
      rescue ArgumentError
        render_invalid_type
      end

      def destroy
        @sensor.destroy
        head :no_content
      end

      private

      # Coleção/criação: aninhadas no talhão (shallow) e escopadas ao usuário.
      def set_field
        @field = current_user.fields.find(params[:field_id])
      end

      # Ações de membro: id próprio do sensor, escopado pelo usuário via associação.
      def set_sensor
        @sensor = current_user.sensors.find(params[:id])
      end

      def sensor_params
        params.permit(:sensor_type)
      end

      def render_errors(record)
        render json: { errors: record.errors.full_messages }, status: :unprocessable_content
      end

      # Um sensor_type fora do enum levanta ArgumentError já na atribuição (antes
      # das validações), então o traduzimos para um 422 amigável em vez de 500.
      def render_invalid_type
        valid = Sensor.sensor_types.keys.join(", ")
        render json: { errors: [ "sensor_type inválido (aceitos: #{valid})" ] },
               status: :unprocessable_content
      end
    end
  end
end
