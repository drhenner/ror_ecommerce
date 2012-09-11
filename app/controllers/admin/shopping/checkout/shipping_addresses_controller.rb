class Admin::Shopping::Checkout::ShippingAddressesController < Admin::Shopping::Checkout::BaseController
  def index
    @shipping_address = Address.new
    if !Settings.require_state_in_address  && countries.size == 1
      @shipping_address.country = countries.first
    end
    form_info
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /shopping/addresses/1/edit
  def edit
    @shipping_address = Address.find(params[:id])
  end

  def new
    old_address       = Address.find_by_id(params[:old_address_id])
    attributes        = old_address.try(:address_attributes)
    @shipping_address  = session_admin_cart.customer.addresses.new(attributes)
    if !Settings.require_state_in_address && countries.size == 1
      @shipping_address.country = countries.first
    end
    form_info
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  # POST /shopping/addresses
  # POST /shopping/addresses.xml
  def create
    if params[:address].present?
      @shipping_address = checkout_user.addresses.new(params[:address])
      @shipping_address.default = true          if checkout_user.default_shipping_address.nil?
      @shipping_address.billing_default = true  if checkout_user.default_billing_address.nil?
      @shipping_address.save
    elsif params[:shipping_address_id].present?
      @shipping_address = checkout_user.addresses.find(params[:shipping_address_id])
    end
    respond_to do |format|

      if @shipping_address.id
        update_order_address_id(@shipping_address.id)
        format.html { redirect_to(admin_shopping_checkout_order_url, :notice => 'Address was successfully created.') }
      else
        form_info
        format.html { render :action => "index" }
      end
    end
  end

  # PUT /shopping/addresses/1
  # PUT /shopping/addresses/1.xml
  def update
    @shipping_address = checkout_user.addresses.new(params[:address])

    # if we are editing the current default address then this is the default address
    @shipping_address.default = true if params[:id] == checkout_user.default_shipping_address.try(:id)

    respond_to do |format|
      if @shipping_address.valid? && @shipping_address.save_default_address(checkout_user, params[:address])
        old_shipping_address = checkout_user.addresses.find(params[:id])
        old_shipping_address.update_attributes(:active => false)
        update_order_address_id(@shipping_address.id)
        format.html { redirect_to(admin_shopping_checkout_order_url, :notice => 'Address was successfully updated.') }
      else
        @shipping_address = checkout_user.addresses.find(params[:id])
        @shipping_address.update_attributes(params[:address])
        form_info
        format.html { render :action => "index" }
      end
    end
  end

  def select_address
    address = checkout_user.addresses.find(params[:id])
    update_order_address_id(address.id)
    respond_to do |format|
      format.html { redirect_to admin_shopping_checkout_order_url }
    end
  end

  private

  def form_info
    @shipping_addresses = session_admin_cart.customer.shipping_addresses
    @states     = State.form_selector
  end
  def update_order_address_id(id)
    session_admin_order.update_attributes( :ship_address_id => id )
  end
end
