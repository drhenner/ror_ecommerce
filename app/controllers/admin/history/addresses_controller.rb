class Admin::History::AddressesController < Admin::BaseController
  helper_method :states
  # GET /admin/history/addresses
  def index
    @order = Order.includes({:user => :addresses}).find_by_number(params[:order_id])
    @addresses = @order.user.addresses
  end

  # GET /admin/history/addresses/1
  def show
    @order = Order.includes({:user => :addresses}).find_by_number(params[:order_id])
    @address = Address.find(params[:id])
  end

  # GET /admin/history/addresses/new
  def new
    @order    = Order.includes({:user => :addresses}).find_by_number(params[:order_id])
    @address  = Address.new
  end

  # GET /admin/history/addresses/1/edit
  def edit
    @order    = Order.includes({:user => :addresses}).find_by_number(params[:order_id])
    @address  = Address.find(params[:id])
  end

  # POST /admin/history/addresses
  def create  ##  This create a new address, sets the orders address & redirects to order_history
    @order    = Order.includes([:ship_address, {:user => :addresses}]).find_by_number(params[:order_id])
    @address  = @order.user.addresses.new(allowed_params)

    respond_to do |format|
      if @address.save
        @order.ship_address = @address
        @order.save
        format.html { redirect_to(admin_history_order_url(@order), :notice => 'Address was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/history/addresses/1
  def update ##  This selects a new address, sets the orders address & redirects to order_history
    @order    = Order.includes([:ship_address, {:user => :addresses}]).find_by_number(params[:order_id])
    @address  = Address.find(params[:id])

    respond_to do |format|
      if @address && @order.ship_address = @address
        if @order.save
          format.html { redirect_to(admin_history_order_url(@order) , :notice => 'Address was successfully selected.') }
        else
          format.html { render :action => "edit" }
        end
      else
        format.html { render :action => "edit" }
      end
    end
  end
  private

  def allowed_params
    params.require(:admin_history_address).permit(:address_type_id, :first_name, :last_name, :address1, :address2, :city, :state_id, :state_name, :zip_code, :phone_id, :alternative_phone, :default, :billing_default, :active, :country_id)
  end

  def states
    @states     ||= State.form_selector
  end
end
