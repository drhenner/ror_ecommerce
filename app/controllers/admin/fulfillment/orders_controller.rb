class Admin::Fulfillment::OrdersController < Admin::Fulfillment::BaseController
  helper_method :sort_column, :sort_direction
  # GET /admin/fulfillment/orders
  def index
    @orders = Order.fulfillment_grid(params).order(sort_column + " " + sort_direction).
                                            paginate(:page => pagination_page, :per_page => pagination_rows)

  end

  # GET /admin/fulfillment/orders/1
  def show
    @order = Order.includes([:user, :shipments, {:order_items => [:shipment, :variant]}]).find(params[:id])
    add_to_recent_user(@order.user)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /admin/fulfillment/orders/1/edit
  def edit
    @order = Order.includes([:user, :shipments, {:order_items => [:shipment, :variant]}]).find(params[:id])
    add_to_recent_user(@order.user)
  end


  def create_shipment
    @order = Order.find_by_id(params[:id])
    if @order
      Shipment.create_shipments_with_items(@order)
      @order.reload
    end
  end

  # PUT /admin/fulfillment/orders/1
  def update
    @order    = Order.find_by_id(params[:id])
    @invoice  = @order.invoices.find(params[:invoice_id])

    @payment = @order.capture_invoice(@invoice)

##  several things happen on this request
# => Payment is captured
# => Invoice is updated to log leger transactions
# => Shipment is marked as ready to send and associated to the order_items
# => If everything works send the user to the shipment page


## TODO
# => Allow partial payments
# => mark only order_items that will be shipped

    if @payment && @payment.success?
      render partial: 'success_message'
    else
      render partial: 'failure_message'
    end
  end

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

  protected

  def sort_column
    Order.column_names.include?(params[:sort]) ? params[:sort] : "number"
  end

  def pagination_rows
    params[:rows] ||= 25
    params[:rows].to_i
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
