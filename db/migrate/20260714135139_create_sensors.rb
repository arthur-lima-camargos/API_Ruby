class CreateSensors < ActiveRecord::Migration[8.1]
  def change
    create_table :sensors do |t|
      t.string :sensor_type, null: false
      t.references :field, null: false, foreign_key: true

      t.timestamps
    end
  end
end
