class MovieFilmingLocation < ApplicationRecord
  belongs_to :movie
  belongs_to :filming_location

  validates :movie_id, uniqueness: { scope: :filming_location_id }
end
