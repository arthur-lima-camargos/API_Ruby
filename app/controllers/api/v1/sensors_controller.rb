module Api
  module V1
    class SensorsController < BaseController
      before_action :set_sensor, only: %i[show update destroy summary]

      # Serve duas rotas: aninhada (/fields/:field_id/sensors) e flat (/sensors).
      # Na flat, filtros opcionais por talhão (?field_id=) e por tipo (?sensor_type=),
      # sempre escopados ao usuário. Tipo fora do enum → 422 (mesmo contrato do create).
      def index
        sensors = params[:field_id].present? ? owned_field.sensors : current_user.sensors

        if params[:sensor_type].present?
          return render_invalid_type unless Sensor.sensor_types.key?(params[:sensor_type])

          sensors = sensors.where(sensor_type: params[:sensor_type])
        end

        render json: SensorSerializer.new(sensors).serializable_hash
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
        sensor = owned_field.sensors.build(sensor_params)

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

      # Talhão do usuário pelo id da rota/query. Talhão de outro usuário → 404,
      # sem vazar existência. Usado na criação (aninhada) e no filtro ?field_id=.
      def owned_field
        current_user.fields.find(params[:field_id])
      end

      # Ações de membro: id próprio do sensor, escopado pelo usuário via associação.
      def set_sensor
        @sensor = current_user.sensors.find(params[:id])
      end

      def sensor_params
        params.permit(:sensor_type)
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
