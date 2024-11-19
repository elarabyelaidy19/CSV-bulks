class CreateMovieFilmingLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :movie_filming_locations do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :filming_location, null: false, foreign_key: true
      t.timestamps
    end

    add_index :movie_filming_locations, [ :movie_id, :filming_location_id ], unique: true
  end
end
