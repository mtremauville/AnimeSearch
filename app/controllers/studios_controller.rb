class StudiosController < ApplicationController
  def index
    @studios = Studio.joins(:animes).distinct.order(:name)
  end

  def show
    @studio = Studio.find(params[:id])
    @animes = @studio.animes.order(score: :desc)
  end
end
