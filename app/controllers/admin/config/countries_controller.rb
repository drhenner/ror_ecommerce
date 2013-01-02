class Admin::Config::CountriesController < ApplicationController
  helper_method :sort_column, :sort_direction
  def index
    params[:page] ||= 1
    params[:rows] ||= 20
    @countries = Country.order(sort_column + " " + sort_direction).
                                              paginate(:page => params[:page].to_i, :per_page => params[:rows].to_i)
  end

  def update
    @country = Country.find(params[:id])
    @country.active = true
    if @country.save
      redirect_to admin_config_countries_url, :notice  => "Successfully activated country."
    else
      form_info
      render :edit
    end
  end

  def destroy
    @country = Country.find(params[:id])
    @country.active = false
    @country.save
    redirect_to admin_config_countries_url, :notice => "Successfully inactivated country."
  end

  private
    def form_info

    end

    def sort_column
      Country.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
