class AnimesController < ApplicationController
  def index
    @genres  = Genre.order(:name)
    @studios = Studio.order(:name)
    @years   = Anime.distinct.order(year: :desc).pluck(:year).compact
  end

  def show
    @anime = Anime.includes(:genres, :studios).find(params[:id])
  end
end
