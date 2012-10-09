class Admin::Shopping::Checkout::BillingAddressesController < Admin::Shopping::Checkout::BaseController
  def index
    @billing_address = Address.new
    if !Settings.require_state_in_address  && countries.size == 1
      @billing_address.country = countries.first
    end
    form_info
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    old_address       = Address.find_by_id(params[:old_address_id])
    attributes        = old_address.try(:address_attributes)
    @billing_address = session_admin_cart.customer.addresses.new(attributes)
    if !Settings.require_state_in_address && countries.size == 1
      @billing_address.country = countries.first
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
      @billing_address = checkout_user.addresses.new(params[:address])
      @billing_address.default = true          if checkout_user.default_billing_address.nil?
      @billing_address.billing_default = true  if checkout_user.default_billing_address.nil?
      @billing_address.save
    elsif params[:billing_address_id].present?
      @billing_address = checkout_user.addresses.find(params[:billing_address_id])
    end
    respond_to do |format|

      if @billing_address.id
        update_order_address_id(@billing_address.id)
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
    @billing_address = checkout_user.addresses.new(params[:address])

    # if we are editing the current default address then this is the default address
    @billing_address.default = true if params[:id] == checkout_user.default_billing_address.try(:id)

    respond_to do |format|
      if @billing_address.valid? && @billing_address.save_default_address(checkout_user, params[:address])
        old_billing_address = checkout_user.addresses.find(params[:id])
        old_billing_address.update_attributes(:active => false)
        update_order_address_id(@billing_address.id)
        format.html { redirect_to(admin_shopping_checkout_order_url, :notice => 'Address was successfully updated.') }
      else
        @billing_address = checkout_user.addresses.find(params[:id])
        @billing_address.update_attributes(params[:address])
        @states     = State.form_selector
        format.html { render :action => "edit" }
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
    @billing_addresses = session_admin_cart.customer.billing_addresses
    @states     = State.form_selector
  end
  def update_order_address_id(id)
    session_admin_order.update_attributes( :bill_address_id => id )
  end
end
