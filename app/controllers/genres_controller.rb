class GenresController < ApplicationController
  def index
    @genres = Genre.joins(:animes).distinct.order(:name)
  end

  def show
    @genre  = Genre.find(params[:id])
    @animes = @genre.animes.order(score: :desc)
  end
end
