class Admin::Config::ShippingMethodsController < Admin::Config::BaseController
  # GET /admin/config/shipping_methods
  def index
    @shipping_methods = ShippingMethod.all
  end

  # GET /admin/config/shipping_methods/new
  def new

    form_info
    if @shipping_zones.empty?
        flash[:notice] = "You must create a Shipping Zone before you create a Shipping Method."
        redirect_to new_admin_config_shipping_zone_path
    else
      @shipping_method = ShippingMethod.new
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  end

  # GET /admin/config/shipping_methods/1/edit
  def edit
    @shipping_method = ShippingMethod.find(params[:id])
    form_info
  end

  # POST /admin/config/shipping_methods
  def create
    @shipping_method = ShippingMethod.new(params[:shipping_method])

    respond_to do |format|
      if @shipping_method.save
        format.html { redirect_to(admin_config_shipping_methods_url, :notice => 'Shipping method was successfully created.') }
      else
        form_info
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/config/shipping_methods/1
  def update
    @shipping_method = ShippingMethod.find(params[:id])

    respond_to do |format|
      if @shipping_method.update_attributes(params[:shipping_method])
        format.html { redirect_to(admin_config_shipping_methods_url, :notice => 'Shipping method was successfully updated.') }
      else
        form_info
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/config/shipping_methods/1
  #def destroy
  #  @shipping_method = ShippingMethod.find(params[:id])
  #  #@shipping_method.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to(admin_config_shipping_methods_url) }
  #    format.xml  { head :ok }
  #  end
  #end

  private

  def form_info
    @shipping_zones = ShippingZone.all.map{|sz| [sz.name, sz.id]}
  end
end
