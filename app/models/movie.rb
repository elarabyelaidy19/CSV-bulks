class Movie < ApplicationRecord
  has_many :movie_actors, dependent: :destroy
  has_many :actors, through: :movie_actors
  has_many :movie_filming_locations, dependent: :destroy
  has_many :filming_locations, through: :movie_filming_locations
  has_many :reviews, dependent: :destroy

  with_options presence: true do
    validates :title
    validates :country
    validates :description
  end
end
