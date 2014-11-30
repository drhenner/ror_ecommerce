class StatesController < ApplicationController

  def index
    @states = State.all_with_country_id(params[:country_id]) if params[:country_id].present?
  end
end
