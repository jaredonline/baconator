class ActorsController < ApplicationController
  def index
    actors = Actor.where.not(name: "Kevin Bacon")#.where.not(bacon_link_id: nil)
    respond_to do |format|
      format.json { render json: actors.to_json }
    end
  end

  def show
    actor = Actor.find actor_params[:id]
    path  = actor.full_bacon_path

    respond_to do |format|
      format.json { render json: path.to_json }
    end
  end

  private
  def actor_params
    params.permit(:id)
  end
end
