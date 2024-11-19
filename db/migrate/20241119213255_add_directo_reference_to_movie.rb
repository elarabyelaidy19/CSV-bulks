class AddDirectoReferenceToMovie < ActiveRecord::Migration[8.0]
  def change
    add_reference :movies, :director, foreign_key: true, index: true
  end
end
