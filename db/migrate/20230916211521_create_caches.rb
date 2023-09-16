class CreateCaches < ActiveRecord::Migration[7.0]
  def change
    create_table :caches do |t|
      t.text :value
      t.string :key, unique: true, null: false
      t.integer :data_type, null: false

      t.timestamps
    end
  end
end
