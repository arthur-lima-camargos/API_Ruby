class CreateFields < ActiveRecord::Migration[8.1]
  def change
    create_table :fields do |t|
      t.string :name, null: false
      t.string :crop
      t.references :farm, null: false, foreign_key: true

      t.timestamps
    end
  end
end
