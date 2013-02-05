class Admin::Shopping::Checkout::BaseController < Admin::Shopping::BaseController
  helper_method :session_admin_order

  private

  def checkout_user
    session_admin_cart.customer
  end

  def next_admin_order_form_url
    next_admin_order_form || admin_shopping_checkout_order_url
  end

  def next_admin_order_form()
     # if cart is empty
    if !session_admin_cart.customer_id
      return admin_shopping_users_url
    elsif !session_admin_cart.shopping_cart_items
      return admin_shopping_products_url()
    elsif session_admin_order.ship_address_id.nil?
      return admin_shopping_checkout_shipping_addresses_url
    elsif session_admin_order.bill_address_id.nil?
      return admin_shopping_checkout_billing_addresses_url()
    elsif session_admin_order.order_items.any?{|oi| oi.shipping_rate_id.nil?}
      return admin_shopping_checkout_shipping_methods_url()
    else
      return nil #admin_shopping_carts_url()
#    elsif session_admin_cart[:coupon].nil?
#      return admin_shopping_coupons_url()
    end
  end

  def session_admin_order
    find_or_create_order
  end

  def session_order_id
    session[:order_admin_id] ? session[:order_admin_id] : find_or_create_order.id
  end

  def find_or_create_order
    return @session_admin_order if @session_admin_order
    if session[:order_admin_id]
      @session_admin_order = checkout_user.orders.include_checkout_objects.find_by_id(session[:order_admin_id])
      create_order if !@session_admin_order || !@session_admin_order.in_progress?
    else
      create_order
    end
    @session_admin_order
  end


  def create_order
    @session_admin_order = checkout_user.orders.create(:number       => Time.now.to_i,
                                                :ip_address   => request.env['REMOTE_ADDR'],
                                                :bill_address => checkout_user.billing_address  )
    add_new_cart_items(session_cart.shopping_cart_items)
    session[:order_admin_id] = @session_admin_order.id
  end

  def add_new_cart_items(items)
    items.each do |item|
      @session_admin_order.add_items(item.variant, item.quantity)
    end
  end

  def order_completed!(order)
    session_admin_cart.mark_items_purchased(order)
    session[:admin_cart_id] = nil
    session[:order_admin_id] = nil
  end
  def countries
    @countries ||= Country.active
  end
end
