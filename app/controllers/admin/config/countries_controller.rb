class Admin::Config::CountriesController < Admin::Config::BaseController
  helper_method :sort_column, :sort_direction, :shipping_zones
  def index
    params[:page] ||= 1
    params[:rows] ||= 20
    @countries = Country.order(sort_column + " " + sort_direction).
                        paginate(:page => params[:page].to_i, :per_page => params[:rows].to_i)
  end

  def edit
    @country = Country.find(params[:id])
    form_info
  end

  def update
    @country = Country.find(params[:id])
    if @country.update_attributes(params[:country])
      redirect_to admin_config_countries_url, :notice  => "Successfully updated country."
    else
      form_info
      render :edit
    end
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

    def shipping_zones
      @shipping_zones ||= ShippingZone.all.map{|sz| [sz.name, sz.id]}
    end
end
