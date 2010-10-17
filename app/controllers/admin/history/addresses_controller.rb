class Admin::History::AddressesController < Admin::BaseController
  # GET /admin/history/addresses
  # GET /admin/history/addresses.xml
  def index
    @order = Order.includes({:user => :addresses}).find_by_number(params[:order_id])
    @addresses = @order.user.addresses

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/history/addresses/1
  # GET /admin/history/addresses/1.xml
  def show
    @order = Order.includes({:user => :addresses}).find_by_number(params[:order_id])
    @address = Address.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/history/addresses/new
  # GET /admin/history/addresses/new.xml
  def new
    @order    = Order.includes({:user => :addresses}).find_by_number(params[:order_id])
    @address  = Address.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/history/addresses/1/edit
  def edit
    @order    = Order.includes({:user => :addresses}).find_by_number(params[:order_id])
    @address  = Address.find(params[:id])
  end

  # POST /admin/history/addresses
  # POST /admin/history/addresses.xml
  def create  ##  This create a new address, sets the orders address & redirects to order_history
    @order    = Order.includes([:ship_address, {:user => :addresses}]).find_by_number(params[:order_id])
    @address  = Address.new(params[:admin_history_address])

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
  # PUT /admin/history/addresses/1.xml
  def update ##  This selects a new address, sets the orders address & redirects to order_history
    @order    = Order.includes([:ship_address, {:user => :addresses}]).find_by_number(params[:order_id])
    @address  = Address.find(params[:id])

    respond_to do |format|
      if @address && @order.ship_address = @address
        @order.save
        format.html { redirect_to(admin_history_order_url(@order) , :notice => 'Address was successfully selected.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

end
