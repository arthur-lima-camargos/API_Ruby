class CreateReadings < ActiveRecord::Migration[8.1]
  def change
    create_table :readings do |t|
      # value como decimal (não float) para medições exatas, sem erro de arredondamento binário.
      t.decimal :value, precision: 8, scale: 2, null: false
      # recorded_at é quando o sensor mediu, distinto de created_at (quando o registro entrou no banco).
      t.datetime :recorded_at, null: false
      t.references :sensor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
