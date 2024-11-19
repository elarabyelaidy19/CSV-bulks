class FilmingLocation < ApplicationRecord
  has_many :movie_filming_locations, dependent: :destroy
  has_many :movies, through: :movie_filming_locations

  validates :name, presence: true
end
