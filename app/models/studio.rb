class Studio < ApplicationRecord
  has_many :anime_studios, dependent: :destroy
  has_many :animes, through: :anime_studios
end
