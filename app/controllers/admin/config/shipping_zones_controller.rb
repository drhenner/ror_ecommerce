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
    @shipping_zone = ShippingZone.new(params[:shipping_zone])

    respond_to do |format|
      if @shipping_zone.save
        format.html { redirect_to(admin_config_shipping_zones_url(), :notice => 'Shipping zone was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/config/shipping_zones/1
  def update
    @shipping_zone = ShippingZone.find(params[:id])

    respond_to do |format|
      if @shipping_zone.update_attributes(params[:shipping_zone])
        format.html { redirect_to(admin_config_shipping_zones_url(), :notice => 'Shipping zone was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

end
