class Admin::Config::ShippingZonesController < Admin::Config::BaseController
  # GET /admin/config/shipping_zones
  def index
    @shipping_zones = ShippingZone.all
  end

  # GET /admin/config/shipping_zones/1
  def show
    @shipping_zone = ShippingZone.find(params[:id])
  end

  # GET /admin/config/shipping_zones/new
  def new
    @shipping_zone = ShippingZone.new
  end

  # GET /admin/config/shipping_zones/1/edit
  def edit
    @shipping_zone = ShippingZone.find(params[:id])
  end

  # POST /admin/config/shipping_zones
  def create
    @shipping_zone = ShippingZone.new(allowed_params)

    if @shipping_zone.save
      redirect_to(admin_config_shipping_zones_url(), notice: 'Shipping zone was successfully created.')
    else
      render action: "new"
    end
  end

  # PUT /admin/config/shipping_zones/1
  def update
    @shipping_zone = ShippingZone.find(params[:id])

    if @shipping_zone.update_attributes(allowed_params)
      redirect_to(admin_config_shipping_zones_url(), notice: 'Shipping zone was successfully updated.')
    else
      render action: "edit"
    end
  end

  protected

  def allowed_params
    params.require(:shipping_zone).permit(:name)
  end

end
