class MoviesController < ApplicationController
  def index
    @movies = Movie.all

    respond_to do |format|
      format.html
      format.json { render json: @movies }
    end
  end

  def search_by_actor
    @movies = Movie.search_by_actor(params[:actor_name])

    respond_to do |format|
      format.html { render partial: "search_results" }
      format.json { render json: @movies }
    end
  end
end
