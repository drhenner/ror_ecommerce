class Shopping::CartItemsController < Shopping::BaseController

  # GET /shopping/cart_items
  def index
    @cart_items       = session_cart.shopping_cart_items.includes(:variant, variant: [:variant_properties, :inventory, :product, product: [:brand, :images]])
    @saved_cart_items = session_cart.saved_cart_items.includes(:variant, variant: [:variant_properties, :inventory, :product, product: [:brand, :images]])
  end

  # POST /shopping/cart_items
  def create
    unless params[:cart_item].present? && params[:cart_item][:variant_id].present?
      flash[:alert] = I18n.t('something_went_wrong')
      redirect_to(root_url) and return
    end
    session_cart.save if session_cart.new_record?
    qty = [params[:cart_item][:quantity].to_i, 1].max
    if cart_item = session_cart.add_variant(params[:cart_item][:variant_id], most_likely_user, qty)
      flash[:notice] = [I18n.t('out_of_stock_notice'), I18n.t('item_saved_for_later')].compact.join(' ') unless cart_item.shopping_cart_item?
      session_cart.save_user(most_likely_user)
      redirect_to(shopping_cart_items_url)
    else
      variant = Variant.includes(:product).find_by_id(params[:cart_item][:variant_id])
      if variant
        redirect_to(product_url(variant.product))
      else
        flash[:notice] = I18n.t('something_went_wrong')
        redirect_to(root_url())
      end
    end
  end

  # PUT /carts/1
  def update
    if session_cart.update(allowed_params)
      if params[:commit]&.downcase == "checkout"
        unless current_user
          session[:return_to] = shopping_orders_url
          redirect_to(login_url) and return
        end
        redirect_to(checkout_shopping_order_url(find_or_create_order))
      else
        redirect_to(shopping_cart_items_url(), notice: I18n.t('item_passed_update') )
      end
    else
      redirect_to(shopping_cart_items_url(),   notice: I18n.t('item_failed_update') )
    end
  end
## TODO
  ## This method moves saved_cart_items to your shopping_cart_items or saved_cart_items
  #   this method is called using AJAX and returns json. with the object moved,
  #   otherwise false is returned if there is an error
  #   method => PUT
  def move_to
    allowed_item_types = [ItemType::SHOPPING_CART_ID, ItemType::SAVE_FOR_LATER_ID, ItemType::WISH_LIST_ID]
    item_type_id = params[:item_type_id].to_i
    unless allowed_item_types.include?(item_type_id)
      redirect_to(shopping_cart_items_url(), alert: I18n.t('item_failed_update')) and return
    end
    @cart_item = session_cart.cart_items.find(params[:id])
    if @cart_item.update(item_type_id: item_type_id)
      redirect_to(shopping_cart_items_url() )
    else
      redirect_to(shopping_cart_items_url(), notice: I18n.t('item_failed_update') )
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.xml
  def destroy
    session_cart.remove_variant(params[:variant_id]) if params[:variant_id].present?
    redirect_to(shopping_cart_items_url)
  end

  private
  def allowed_params
    params.require(:cart).permit(shopping_cart_items_attributes: [:id, :quantity])
  end

end
