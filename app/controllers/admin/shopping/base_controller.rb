#The philosophy of the admin cart is 2-fold.
#
# First these people have admin privileges.  So lets not add security features that they are allowed to use anyway.
#
# Second, the number of people in the Admin Section will not be in the millions.
# => So lets use the mem_cache session store to store more information than we would normal.
# => This will hit the DB much less and should have better performance.

class Admin::Shopping::BaseController < Admin::BaseController
  helper_method :session_admin_cart, :reset_admin_cart#, :new_admin_cart#

  layout 'admin_cart'

  private

  def reset_admin_cart
    session[:admin_cart_id] = new_admin_cart.id
  end

  def session_admin_cart
    if session[:admin_cart_id]
      @admin_cart ||= Cart.find_by_id(session[:admin_cart_id])
      @admin_cart ||= new_admin_cart # just in case the session has a bad ID (normally in development while having 2 apps)
    else
      new_admin_cart
    end
  end

  def new_admin_cart
    @admin_cart = Cart.create(:user => current_user)
    session[:admin_cart_id] = @admin_cart.id
    @admin_cart
  end

  def next_admin_cart_form()
     # if cart is empty
    if !session_admin_cart.customer_id
      return admin_shopping_users_url
    elsif !session_admin_cart.shopping_cart_items
      return admin_shopping_products_url()
    #elsif session_admin_cart[:shipping_address].nil?
    #  return admin_shopping_shipping_addresses_url
    #elsif session_admin_cart[:billing_address].nil?
    #  return admin_shopping_billing_addresses_url()
    #elsif session_admin_cart[:shipping_rate].nil?
    #  return admin_shopping_shipping_methods_url()
    else
      return admin_shopping_products_url()
    #  return nil#admin_shopping_carts_url()
#    elsif session_admin_cart[:coupon].nil?
#      return admin_shopping_coupons_url()
    end
  end

end