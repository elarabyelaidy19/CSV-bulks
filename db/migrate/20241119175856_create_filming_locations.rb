class CreateFilmingLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :filming_locations do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :filming_locations, :name
  end
end
