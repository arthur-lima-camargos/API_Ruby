module Api
  module V1
    class ReadingsController < BaseController
      before_action :set_sensor

      # Histórico do sensor em ordem cronológica (mais antigas primeiro), útil
      # para análise de tendência. Aceita recorte por intervalo (?from=&to=) e
      # paginação simples (?page=&per_page=).
      def index
        readings = @sensor.readings
                          .then { |scope| filter_by_range(scope) }
                          .order(:recorded_at)
                          .then { |scope| paginate(scope) }

        render json: ReadingSerializer.new(readings).serializable_hash
      end

      def create
        reading = @sensor.readings.build(reading_params)
        reading.recorded_at ||= Time.current

        if reading.save
          render json: ReadingSerializer.new(reading).serializable_hash, status: :created
        else
          render json: { errors: reading.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def set_sensor
        @sensor = current_user.sensors.find(params[:sensor_id])
      end

      def reading_params
        params.permit(:value, :recorded_at)
      end

      def filter_by_range(scope)
        scope = scope.where(recorded_at: params[:from]..) if params[:from].present?
        scope = scope.where(recorded_at: ..params[:to]) if params[:to].present?
        scope
      end

      # Paginação enxuta sem gem: per_page padrão 50, teto de 100.
      def paginate(scope)
        page = [ params.fetch(:page, 1).to_i, 1 ].max
        per_page = params.fetch(:per_page, 50).to_i.clamp(1, 100)
        scope.limit(per_page).offset((page - 1) * per_page)
      end
    end
  end
end
