class Myaccount::OrdersController < Myaccount::BaseController
  # GET /myaccount/orders
  # GET /myaccount/orders.xml
  def index
    @orders = current_user.finished_orders.find_myaccount_details
  end

  # GET /myaccount/orders/1
  # GET /myaccount/orders/1.xml
  def show
    @order = current_user.finished_orders.includes([:invoices]).find_by_number(params[:id])
  end
  private

  def selected_myaccount_tab(tab)
    tab == 'orders'
  end
end
