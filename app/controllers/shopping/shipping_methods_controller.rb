class Shopping::ShippingMethodsController < Shopping::BaseController
  # GET /shopping/shipping_methods
  # GET /shopping/shipping_methods.xml
  def index
    unless find_or_create_order.ship_address_id
      flash[:notice] = 'Select an address before you select a shipping method.'
      redirect_to shopping_addresses_url
    else
      ##  TODO  refactopr this method... it seems a bit lengthy
      @shipping_method_ids = session_order.ship_address.state.shipping_zone.shipping_method_ids
      
      @order_items = OrderItem.includes({:variant => {:product => :shipping_category}}).order_items_in_cart(session_order.id)
      #session_order.order_
      @order_items.each do |item|
        item.variant.product.available_shipping_rates = ShippingRate.with_these_shipping_methods(item.variant.product.shipping_category.shipping_rate_ids, @shipping_method_ids)
      end
      
      respond_to do |format|
        format.html # index.html.erb
      end
    end
  end

  # GET /shopping/shipping_methods/1
  # GET /shopping/shipping_methods/1.xml
  def show
    @shipping_method = ShippingMethod.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shipping_method }
    end
  end

  # GET /shopping/shipping_methods/1/edit
  def edit
    @shipping_method = ShippingMethod.find(params[:id])
  end

  # POST /shopping/shipping_methods
  # POST /shopping/shipping_methods.xml
  def create
    @shipping_method = ShippingMethod.new(params[:shopping_shipping_method])

    respond_to do |format|
      if @shipping_method.save
        format.html { redirect_to(@shipping_method, :notice => 'Shipping method was successfully created.') }
        format.xml  { render :xml => @shipping_method, :status => :created, :location => @shipping_method }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shipping_method.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shopping/shipping_methods/1
  # PUT /shopping/shipping_methods/1.xml
  def update
    all_selected = true
    params[:shipping_category].each_pair do |category_id, rate_id|#[rate]
      if rate_id
        items = OrderItem.includes([{:variant => :product}]).
                          where(['order_items.order_id = ? AND 
                                  products.shipping_category_id = ?', session_order_id, category_id])
      
        OrderItem.update_all("shipping_rate_id = #{rate_id}","id IN (#{items.map{|i| i.id}.join(',')})")
      else
        all_selected = false
      end
    end
    respond_to do |format|
      if all_selected
        format.html { redirect_to(shopping_orders_url, :notice => 'Shipping method was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { redirect_to( shopping_shipping_methods_url, :notice => 'All the Shipping Methods must be selected') }
      end
    end
  end

  # DELETE /shopping/shipping_methods/1
  # DELETE /shopping/shipping_methods/1.xml
  def destroy
    @shipping_method = ShippingMethod.find(params[:id])
    @shipping_method.destroy

    respond_to do |format|
      format.html { redirect_to(shopping_shipping_methods_url) }
      format.xml  { head :ok }
    end
  end
end
