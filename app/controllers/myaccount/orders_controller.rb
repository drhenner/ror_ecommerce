class Myaccount::OrdersController < Myaccount::BaseController
  # GET /myaccount/orders
  # GET /myaccount/orders.xml
  def index
    @orders = current_user.completed_orders.find_myaccount_details

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /myaccount/orders/1
  # GET /myaccount/orders/1.xml
  def show
    @order = current_user.completed_orders.includes([:invoices]).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

end
