class CreateFarms < ActiveRecord::Migration[8.1]
  def change
    create_table :farms do |t|
      t.string :name, null: false
      t.string :location
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
