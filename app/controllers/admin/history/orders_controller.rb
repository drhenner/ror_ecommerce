class Admin::History::OrdersController < Admin::BaseController
  # GET /admin/history/orders
  def index
    @pagy, @orders = pagy(Order.find_finished_order_grid(params), limit: pagination_rows)
  end

  # GET /admin/history/orders/1
  def show
    @order = Order.includes([:ship_address, :invoices,
                             {:shipments => :shipping_method},
                             {:order_items => [
                                                {:variant => [:product, :variant_properties]}]
                              }]).find_by_number(params[:id])
  end

end
