class Admin::Shopping::Checkout::ShippingMethodsController < Admin::Shopping::Checkout::BaseController

  def index
    unless find_or_create_order.ship_address_id
      flash[:notice] = I18n.t('select_address_before_shipping_method')
      redirect_to admin_shopping_checkout_shipping_addresses_url
    else
      ##  TODO  refactopr this method... it seems a bit lengthy
      @shipping_method_ids = session_admin_order.ship_address.state.shipping_zone.shipping_method_ids
      session_admin_order.find_sub_total
      @order_items = OrderItem.includes({:variant => {:product => :shipping_category}}).order_items_in_cart(session_admin_order.id)
      #session_order.order_
      @order_items.each do |item|
        item.variant.product.available_shipping_rates = ShippingRate.with_these_shipping_methods(item.variant.product.shipping_category.shipping_rate_ids, @shipping_method_ids)
      end

      respond_to do |format|
        format.html # index.html.erb
      end
    end
  end

  def update
    all_selected = true
    params[:shipping_category].each_pair do |category_id, rate_id|#[rate]
      if rate_id
        items = order_items_with_category(category_id)

        OrderItem.update_all("shipping_rate_id = #{rate_id}","id IN (#{items.map{|i| i.id}.join(',')})")
      else
        all_selected = false
      end
    end
    respond_to do |format|
      if all_selected
        format.html { redirect_to(admin_shopping_checkout_order_url, :notice => I18n.t('shipping_method_updated')) }
      else
        format.html { redirect_to( admin_shopping_checkout_shipping_methods_url, :notice => I18n.t('all_shipping_methods_must_be_selected')) }
      end
    end
  end
  private

  def order_items_with_category(category_id)
    items = OrderItem.includes([{:variant => :product}]).
                      where(['order_items.order_id = ? AND
                              products.shipping_category_id = ?', session_order_id, category_id])
  end

  def form_info

  end
end
