class Admin::Fulfillment::OrdersController < Admin::Fulfillment::BaseController
  # GET /admin/fulfillment/orders
  # GET /admin/fulfillment/orders.xml
  def index
    @orders = Order.fulfillment_grid(params)

    respond_to do |format|
      format.html # index.html.erb
      
      format.json { render :json => @orders.to_jqgrid_json(
        [ :display_completed_at, :email, :number, :name ],
        @orders.per_page,
        @orders.current_page, 
        @orders.total_entries)

      }
    end
  end

  # GET /admin/fulfillment/orders/1
  # GET /admin/fulfillment/orders/1.xml
  def show
    @order = Order.includes([:shipments, {:order_items => [:shipment, :variant]}]).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /admin/fulfillment/orders/new
  # GET /admin/fulfillment/orders/new.xml
  def new
    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/fulfillment/orders/1/edit
  def edit
    @order = Order.includes([:shipments, {:order_items => [:shipment, :variant]}]).find(params[:id])
  end

  # POST /admin/fulfillment/orders
  # POST /admin/fulfillment/orders.xml
  def create
    @order = Order.new(params[:order])

    respond_to do |format|
      if @order.save
        format.html { redirect_to(admin_fulfillment_orders_path(@order.id), :notice => 'Order was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/fulfillment/orders/1
  # PUT /admin/fulfillment/orders/1.xml
  def update
    @order    = Order.find(params[:id])
    @invoice  = @order.invoices.find(params[:invoice_id])
    
    payment = @order.capture_invoice(@invoice)

##  several things happen on this request
# => Payment is captured
# => Invoice is updated to log leger transactions
# => Shipment is marked as ready to send and associated to the order_items
# => If everything works send the user to the shipment page


## TODO
# => Allow partial payments
# => mark only order_items that will be shipped

    respond_to do |format|
      if payment && payment.success?
        @shipments = Shipment.create_shipments_with_items(@order)
        # reload order
        format.html { render :partial => 'success_message' }
        #format.html { redirect_to(admin_fulfillment_order_path(@order), :notice => 'Shipment was successfully updated.') }
      else
        debugger
        format.html { render :partial => 'failure_message' }
      end
    end
  end

=begin

# POST /shopping/orders
# POST /shopping/orders.xml
def update
  @order = find_or_create_order
  @order.ip_address = request.remote_ip
  
  @credit_card ||= ActiveMerchant::Billing::CreditCard.new(cc_params)
  #gateway = ActiveMerchant::Billing::PaypalGateway.new(:login=>$PAYPAL_LOGIN, :password=>$PAYPAL_PASSWORD)

  #res = gateway.authorize(amount, credit_card, :ip=>request.remote_ip, :billing_address=>billing_address)
  address = @order.bill_address.cc_params
  
  if @credit_card.valid?
    if response = @order.create_invoice(@credit_card, @order.find_total, {:email => @order.email, :billing_address=> address, :ip=> @order.ip_address })
      if response.success?
        render :action => "success"
      else
        render :action => "failure"
      end
    else
      render :action => 'index'
    end
  else
    flash[:error] = "Credit Card is not valid."
    render :action => 'index'
  end
end

=end

  # DELETE /admin/fulfillment/shipments/1
  # DELETE /admin/fulfillment/shipments/1.xml
  def destroy
    
    @order    = Order.find(params[:id])
    @invoice  = @order.invoices.find(params[:invoice_id])
    
    @order.cancel_unshipped_order(@invoice)
    respond_to do |format|
      format.html { render :partial => 'invoice_details', :locals => {:invoice => @invoice} }
      format.json { render :json => @order.to_json }
    end
  end

end
