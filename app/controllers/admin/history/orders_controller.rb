class Admin::History::OrdersController < Admin::BaseController
  # GET /admin/history/orders
  # GET /admin/history/orders.xml
  def index
    @orders = Order.find_finished_order_grid(params)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/history/orders/1
  # GET /admin/history/orders/1.xml
  def show
    @order = Order.includes([:ship_address, :invoices, 
                             {:shipments => :shipping_method},
                             {:order_items => [
                                                {:variant => [:product, :variant_properties]}]
                              }]).find_by_number(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /admin/history/orders/new
  # GET /admin/history/orders/new.xml
  def new
    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /admin/history/orders/1/edit
  def edit
    @order = Order.find_by_number(params[:id])
  end

  # POST /admin/history/orders
  # POST /admin/history/orders.xml
  def create
    @order = Order.new(params[:order])

    respond_to do |format|
      if @order.save
        format.html { redirect_to(@order, :notice => 'Order was successfully created.') }
        format.xml  { render :xml => @order, :status => :created, :location => @order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/history/orders/1
  # PUT /admin/history/orders/1.xml
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        format.html { redirect_to(@order, :notice => 'Order was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/history/orders/1
  # DELETE /admin/history/orders/1.xml
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to(admin_history_orders_url) }
      format.xml  { head :ok }
    end
  end
end
