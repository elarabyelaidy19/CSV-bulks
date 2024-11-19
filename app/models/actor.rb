class Actor < ApplicationRecord
  validates :name, presence: true

  has_many :movie_actors, dependent: :destroy
  has_many :movies, through: :movie_actors
end
