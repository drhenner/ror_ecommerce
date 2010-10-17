class Admin::Shopping::ShippingAddressesController < Admin::Shopping::BaseController
  # GET /admin/order/shipping_addresses
  # GET /admin/order/shipping_addresses.xml
  def index
    @shipping_addresses = session_admin_cart[:user].shipping_addresses

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/order/shipping_addresses/new
  # GET /admin/order/shipping_addresses/new.xml
  def new
    old_address       = Address.find_by_id(params[:old_address_id])
    attributes        = old_address.try(:address_atributes)
    @shipping_address = session_admin_cart[:user].addresses.new(attributes)
    form_info
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # PUT /admin/order/shipping_addresses/1
  # PUT /admin/order/shipping_addresses/1.xml
  def create
    old_address       = Address.find_by_id(params[:old_address_id])
    @shipping_address = session_admin_cart[:user].addresses.new(params[:address])
    if old_address && (old_address.default? || old_address.billing_default?)
      @shipping_address.default = true         if old_address.default?
      @shipping_address.billing_default = true if old_address.billing_default?
    end
    respond_to do |format|
      if @shipping_address.save#update_attributes(params[:admin_shopping_shipping_address])
        if old_address
          old_address.default = false
          old_address.billing_default = false
          old_address.inactive!
        end
        session_admin_cart[:shipping_address] = @shipping_address
        format.html { redirect_to(admin_shopping_carts_url, :notice => 'Shipping address was successfully updated.') }
      else
        form_info
        format.html { render :action => "new", :old_address_id => params[:old_address_id] }
      end
    end
  end
  
  def update
    @shipping_address       = Address.find_by_id(params[:id])
    session_admin_cart[:shipping_address] = @shipping_address
    redirect_to(admin_shopping_carts_url, :notice => 'Shipping address was successfully selected.')
  end
  
  private
  
  def form_info
    @shopping_addresses = session_admin_cart[:user].shipping_addresses
    @states     = State.form_selector
  end
  
  #def update_order_address_id(id)
  #  session_order.update_attributes(
  #                        :ship_address_id => id , 
  #                        :bill_address_id => (session_order.bill_address_id ? session_order.bill_address_id : id)
  #                                  )
  #end
end
