class Review < ApplicationRecord
  belongs_to :movie
  belongs_to :user

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comment, presence: true
  validates :movie_id, uniqueness: { scope: :user_id, message: "has already been reviewed" }
end
