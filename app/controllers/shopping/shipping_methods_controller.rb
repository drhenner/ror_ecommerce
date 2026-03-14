class Shopping::ShippingMethodsController < Shopping::BaseController
  before_action :require_user
  # GET /shopping/shipping_methods
  def index
    order = find_or_create_order
    if !order.ship_address_id || order.ship_address.nil?
      order.update(ship_address_id: nil) if order.ship_address.nil?
      flash[:notice] = I18n.t('select_address_before_shipping_method')
      redirect_to shopping_addresses_url
    else
      session_order.find_sub_total
      @shipping_method_ids = session_order.ship_address.shipping_method_ids

      @order_items = OrderItem.includes({:variant => {:product => :shipping_category}}).order_items_in_cart(session_order.id)
      #session_order.order_
      @order_items.each do |item|
        item.variant.product.available_shipping_rates = ShippingRate.with_these_shipping_methods(item.variant.product.shipping_category.shipping_rate_ids, @shipping_method_ids)
      end
    end
  end

  # PUT /shopping/shipping_methods/1
  def update
    all_selected = true
    redirect_to(shopping_orders_url) and return unless params[:shipping_category].present?
    params[:shipping_category].each_pair do |category_id, rate_id|#[rate]
      if rate_id.present?
        unless ShippingRate.where(id: rate_id, shipping_category_id: category_id).exists?
          all_selected = false
          next
        end
        item_ids = OrderItem.includes([{:variant => :product}]).
                             where(['order_items.order_id = ? AND
                                  products.shipping_category_id = ?', session_order_id, category_id]).references(:products).pluck("order_items.id")

        OrderItem.where(id: item_ids).update_all(shipping_rate_id: rate_id)
      else
        all_selected = false
      end
    end
    session_order.update_column(:calculated_at, nil) if all_selected
    if all_selected
      redirect_to(shopping_orders_url, :notice => I18n.t('shipping_method_updated'))
    else
      redirect_to( shopping_shipping_methods_url, :notice => I18n.t('all_shipping_methods_must_be_selected'))
    end
  end

end
