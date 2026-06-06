class Anime < ApplicationRecord
  include AlgoliaSearch

  has_many :anime_genres,  dependent: :destroy
  has_many :genres,  through: :anime_genres
  has_many :anime_studios, dependent: :destroy
  has_many :studios, through: :anime_studios

  algoliasearch index_name: "animes_#{Rails.env}" do
    attributes :title, :title_english, :synopsis, :score,
               :year, :image_url, :status, :episodes, :mal_id

  attribute :genre_names do
    genres.pluck(:name)
  end

  attribute :studio_names do
    studios.pluck(:name)
  end

    searchableAttributes [
      "title",
      "title_english",
      "unordered(synopsis)",
      "unordered(genre_names)",
      "unordered(studio_names)"
    ]

    attributesForFaceting [
      "searchable(genre_names)",
      "searchable(studio_names)",
      "year",
      "status"
    ]

    customRanking [
      "desc(score)",
      "desc(episodes)"
    ]
    attributesToHighlight ["title", "title_english", "synopsis"]
    attributesToSnippet   ["synopsis:30"]

    typoTolerance "min"
  end

  # ← ajouter cette méthode
  def save_without_index!
    Anime.without_auto_index { save! }
  end
end
