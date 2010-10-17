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
    session[:admin_cart] = new_admin_cart
  end
  
  def session_admin_cart
    session[:admin_cart] ? session[:admin_cart] : new_admin_cart
  end
  
  def new_admin_cart
    session[:admin_cart] = {
      :user             => nil,
      :shipping_address => nil,
      :billing_address  => nil,
      :coupon           => nil,
      :shipping_method  => nil,
      :order_items => {}# the key is variant_id , a hash of {variant, shipping_rate, quantity, tax_rate, total, shipping_category_id}
    }
    
#  variants =>  [
#                 :id => {}, 
#                 :id => {:variant => variant, :quantity => 2, :shipping_rate => shipping_rate, :total => 30.85}
#               ]
  end
  
  def next_admin_cart_form()
     # if cart is empty
    if session_admin_cart[:user].nil?
      return admin_shopping_users_url
    elsif session_admin_cart[:shipping_address].nil?
      return admin_shopping_shipping_addresses_url
    elsif session_admin_cart[:billing_address].nil?
      return admin_shopping_billing_addresses_url()
    elsif session_admin_cart[:order_items].blank?
      return admin_shopping_products_url()
    elsif session_admin_cart[:shipping_rate].nil?
      return admin_shopping_shipping_methods_url()
    else
      return nil#admin_shopping_carts_url()
#    elsif session_admin_cart[:coupon].nil?
#      return admin_shopping_coupons_url()
    end
  end
  
end