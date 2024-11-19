class Director < ApplicationRecord
  has_many :movies, dependent: :destroy
  validates :name, presence: true
end
