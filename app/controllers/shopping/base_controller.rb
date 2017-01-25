class Shopping::BaseController < ApplicationController
  helper_method :session_order, :session_order_id
  # these are methods that can be used for all orders

  protected

  def ssl_required?
    ssl_supported?
  end

  private

  def next_form_url(order)
    next_form(order) || shopping_orders_url
  end

  def next_form(order)

    # if cart is empty
    if session_cart.shopping_cart_items.empty?
      flash[:notice] = I18n.t('do_not_have_anything_in_your_cart')
      return products_url
    elsif !session_cart.shopping_cart_items_equal_order_items?(session_order)
      flash[:alert] = I18n.t('shopping_cart_items_do_not_match_order_items')
      return shopping_cart_items_url
    ## If we are insecure
    elsif not_secure?
      session[:return_to] = shopping_orders_url
      return login_url()
    elsif session_order.ship_address_id.nil?
      return shopping_addresses_url()
    elsif !session_order.all_order_items_have_a_shipping_rate?
      return shopping_shipping_methods_url()
    end
  end

  def not_secure?
    !current_user || has_not_logged_in_recently?
  end

  def has_not_logged_in_recently?(minutes = 20)
    session[:authenticated_at].nil? || Time.now - session[:authenticated_at] > (60 * minutes)
  end

  def session_order
    find_or_create_order
  end

  def session_order_id
    session[:order_id] ? session[:order_id] : find_or_create_order.id
  end

  def find_or_create_order
    return @session_order if @session_order
    if session[:order_id]
      @session_order = current_user.orders.include_checkout_objects.find(session[:order_id])
      create_order if !@session_order.in_progress?
    else
      create_order
    end
    @session_order
  end

  def create_order
    @session_order = current_user.orders.create(:number       => Time.now.to_i,
                                                :ip_address   => request.env['REMOTE_ADDR'],
                                                :bill_address => current_user.billing_address  )
    add_new_cart_items(session_cart.shopping_cart_items)
    session[:order_id] = @session_order.id
  end

  def add_new_cart_items(items)
    items.each do |item|
      @session_order.add_items(item.variant, item.quantity)
    end
  end
end
