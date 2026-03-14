class Myaccount::OrdersController < Myaccount::BaseController
  # GET /myaccount/orders
  # GET /myaccount/orders.xml
  def index
    @orders = current_user.finished_orders.find_myaccount_details
  end

  # GET /myaccount/orders/1
  # GET /myaccount/orders/1.xml
  def show
    order_id = Order.id_from_number(params[:id])
    @order = current_user.finished_orders.includes(:invoices, order_items: { variant: :product }).find_by(id: order_id)
    unless @order
      redirect_to myaccount_orders_path, alert: "Order not found."
      return
    end
  end
  private

  def selected_myaccount_tab(tab)
    tab == 'orders'
  end
end
