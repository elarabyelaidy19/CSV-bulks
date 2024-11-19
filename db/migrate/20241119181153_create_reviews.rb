class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :comment, null: false
      t.timestamps
    end

    add_index :reviews, [ :movie_id, :user_id ], unique: true
    add_index :reviews, :rating
  end
end
