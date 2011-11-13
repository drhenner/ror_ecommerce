class Admin::History::OrdersController < Admin::BaseController
  # GET /admin/history/orders
  # GET /admin/history/orders.xml
  def index
    @orders = Order.find_finished_order_grid(params)
  end

  # GET /admin/history/orders/1
  # GET /admin/history/orders/1.xml
  def show
    @order = Order.includes([:ship_address, :invoices,
                             {:shipments => :shipping_method},
                             {:order_items => [
                                                {:variant => [:product, :variant_properties]}]
                              }]).find_by_number(params[:id])
  end

end
