class Admin::Shopping::BillingAddressesController < Admin::Shopping::BaseController
  # GET /admin/order/billing_addresses
  # GET /admin/order/billing_addresses.xml
  def index
    @billing_addresses = session_admin_cart[:user].billing_addresses
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/order/billing_addresses/new
  # GET /admin/order/billing_addresses/new.xml
  def new
    old_address       = Address.find_by_id(params[:old_address_id])
    attributes        = old_address.try(:address_attributes)
    @billing_address = session_admin_cart[:user].addresses.new(attributes)
    form_info
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # PUT /admin/order/billing_addresses/1
  # PUT /admin/order/billing_addresses/1.xml
  def create
    old_address       = Address.find_by_id(params[:old_address_id])
    @billing_address = session_admin_cart[:user].addresses.new(params[:address])
    if old_address && (old_address.default? || old_address.billing_default?)
      @billing_address.default = true         if old_address.default?
      @billing_address.billing_default = true if old_address.billing_default?
    end
    respond_to do |format|
      if @billing_address.save#update_attributes(params[:admin_shopping_billing_address])
        if old_address
          old_address.default = false
          old_address.billing_default = false
          old_address.inactive!
        end
        session_admin_cart[:billing_address] = @billing_address
        format.html { redirect_to(admin_shopping_carts_url, :notice => 'Shipping address was successfully updated.') }
      else
        form_info
        format.html { render :action => "new", :old_address_id => params[:old_address_id] }
      end
    end
  end

  def update
    @billing_address       = Address.find_by_id(params[:id])
    session_admin_cart[:billing_address] = @billing_address
    redirect_to(admin_shopping_carts_url, :notice => 'Shipping address was successfully selected.')
  end

  private

  def form_info
    @billing_addresses = session_admin_cart[:user].billing_addresses
    @states     = State.form_selector
  end
end
