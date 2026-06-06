class Genre < ApplicationRecord
  has_many :anime_genres, dependent: :destroy
  has_many :animes, through: :anime_genres
end
