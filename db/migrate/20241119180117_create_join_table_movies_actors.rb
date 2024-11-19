class CreateJoinTableMoviesActors < ActiveRecord::Migration[8.0]
  def change
    create_join_table :movies, :actors do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: true
    end

    add_index :movies_actors, [:movie_id, :actor_id], unique: true
  end
end
