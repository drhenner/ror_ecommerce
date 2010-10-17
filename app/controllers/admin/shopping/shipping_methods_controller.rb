class Admin::Shopping::ShippingMethodsController < Admin::Shopping::BaseController
  # GET /admin/order/shipping_methods
  # GET /admin/order/shipping_methods.xml
  def index
    @shipping_methods = #session_admin_cart[:user].shipping_addresses

      unless session_admin_cart[:shipping_address]
        flash[:notice] = 'Select an address before you select a shipping method.'
        redirect_to admin_shopping_shipping_addresses_url
      else
        ##  TODO  refactopr this method... it seems a bit lengthy
        @shipping_method_ids = session_admin_cart[:shipping_address].state.shipping_zone.shipping_method_ids

        session_admin_cart[:order_items].each do |item|
          item.second[:variant].product.available_shipping_rates = ShippingRate.with_these_shipping_methods(item.second[:variant].product.shipping_category.shipping_rate_ids, @shipping_method_ids)
        end

        respond_to do |format|
          format.html # index.html.erb
        end
      end
  end

  # PUT /admin/order/shipping_methods/1
  # PUT /admin/order/shipping_methods/1.xml
  def create
    all_selected = true
    params[:shipping_category].each_pair do |category_id, rate_id|#[rate]
      if rate_id
        session_admin_cart[:order_items].each do |item|
          if item.second[:variant].product.shipping_category_id == category_id.to_i
            ship_rate = ShippingRate.find(rate_id) 
            item.second[:shipping_rate] = ship_rate
            
          end
        end
      else
        all_selected = false
      end
    end
    session_admin_cart[:shipping_rate] = all_selected # complete
    respond_to do |format|
      if all_selected
        format.html { redirect_to(admin_shopping_carts_url, :notice => 'Shipping method was successfully selected.') }
      else
        format.html { redirect_to( admin_shopping_shipping_methods_url, :notice => 'All the Shipping Methods must be selected') }
      end
    end
  end

  # GET /admin/order/shipping_methods/1
  # GET /admin/order/shipping_methods/1.xml
#  def show
#    @shipping_method = ShippingMethod.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#    end
#  end
#
#  # GET /admin/order/shipping_methods/new
#  # GET /admin/order/shipping_methods/new.xml
#  def new
#    @shipping_method = ShippingMethod.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#    end
#  end
#
#  # GET /admin/order/shipping_methods/1/edit
#  def edit
#    @admin_shopping_shipping_method = ShippingMethod.find(params[:id])
#  end
#
#  # POST /admin/order/shipping_methods
#  # POST /admin/order/shipping_methods.xml
#  def create
#    @admin_shopping_shipping_method = ShippingMethod.new(params[:admin_shopping_shipping_method])
#
#    respond_to do |format|
#      if @admin_shopping_shipping_method.save
#        format.html { redirect_to(@admin_shopping_shipping_method, :notice => 'Shipping method was successfully created.') }
#        format.xml  { render :xml => @admin_shopping_shipping_method, :status => :created, :location => @admin_shopping_shipping_method }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @admin_shopping_shipping_method.errors, :status => :unprocessable_entity }
#      end
#    end
#  end


end
