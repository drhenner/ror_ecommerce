class StatesController < ApplicationController
  respond_to :xml, :json
  
  def index
    @states = State.all_with_country_id(params[:country_id]) if params[:country_id].present?
  end
end
