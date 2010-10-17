class Admin::Config::ShippingMethodsController < Admin::Config::BaseController
  # GET /admin/config/shipping_methods
  # GET /admin/config/shipping_methods.xml
  def index
    @shipping_methods = ShippingMethod.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shipping_methods }
    end
  end

  # GET /admin/config/shipping_methods/1
  # GET /admin/config/shipping_methods/1.xml
  def show
    @shipping_method = ShippingMethod.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shipping_method }
    end
  end

  # GET /admin/config/shipping_methods/new
  # GET /admin/config/shipping_methods/new.xml
  def new
    
    form_info
    if @shipping_zones.empty?
        flash[:notice] = "You must create a Shipping Zone before you create a Shipping Method."
        redirect_to new_admin_config_shipping_zone_path
    else
      @shipping_method = ShippingMethod.new
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @shipping_method }
      end
    end
  end

  # GET /admin/config/shipping_methods/1/edit
  def edit
    @shipping_method = ShippingMethod.find(params[:id])
    form_info
  end

  # POST /admin/config/shipping_methods
  # POST /admin/config/shipping_methods.xml
  def create
    @shipping_method = ShippingMethod.new(params[:shipping_method])

    respond_to do |format|
      if @shipping_method.save
        format.html { redirect_to(admin_config_shipping_method_url(@shipping_method), :notice => 'Shipping method was successfully created.') }
        format.xml  { render :xml => @shipping_method, :status => :created, :location => @shipping_method }
      else
        form_info
        format.html { render :action => "new" }
        format.xml  { render :xml => @shipping_method.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/config/shipping_methods/1
  # PUT /admin/config/shipping_methods/1.xml
  def update
    @shipping_method = ShippingMethod.find(params[:id])

    respond_to do |format|
      if @shipping_method.update_attributes(params[:shipping_method])
        format.html { redirect_to(admin_config_shipping_method_url(@shipping_method), :notice => 'Shipping method was successfully updated.') }
        format.xml  { head :ok }
      else
        form_info
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shipping_method.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/config/shipping_methods/1
  # DELETE /admin/config/shipping_methods/1.xml
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
    @shipping_zones = ShippingZone.all
  end
end
