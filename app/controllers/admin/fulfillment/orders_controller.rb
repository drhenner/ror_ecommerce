class Admin::Fulfillment::OrdersController < Admin::Fulfillment::BaseController
  helper_method :sort_column, :sort_direction
  # GET /admin/fulfillment/orders
  def index
    @orders = Order.fulfillment_grid(params).order(sort_column + " " + sort_direction).paginate(:per_page => 25, :page => params[:page].to_i)

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
  def show
    @order = Order.includes([:shipments, {:order_items => [:shipment, :variant]}]).find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /admin/fulfillment/orders/1/edit
  def edit
    @order = Order.includes([:shipments, {:order_items => [:shipment, :variant]}]).find(params[:id])
  end

  # PUT /admin/fulfillment/orders/1
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
        format.html { render :partial => 'failure_message' }
      end
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

  private

  def sort_column
    Order.column_names.include?(params[:sort]) ? params[:sort] : "number"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
