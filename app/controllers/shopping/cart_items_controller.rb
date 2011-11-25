class Shopping::CartItemsController < Shopping::BaseController

  # GET /shopping/cart_items
  # GET /shopping/cart_items.xml
  def index
    @cart_items       = session_cart.shopping_cart_items
    @saved_cart_items = session_cart.saved_cart_items
  end

  # POST /shopping/cart_items
  # POST /shopping/cart_items.xml
  def create
    @cart_item = get_new_cart_item
    session_cart.save if session_cart.new_record?
    qty = params[:cart_item][:quantity].to_i
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
  # PUT /carts/1.xml
  def update
    #@cart_item = session_cart.shopping_cart_items.find(params[:id])

    respond_to do |format|
      if session_cart.update_attributes(params[:cart])
        if params[:commit] && params[:commit] == "checkout"
          format.html { redirect_to( checkout_shopping_order_url('checkout')) }
        else
          format.html { redirect_to(shopping_cart_items_url(), :notice => I18n.t('item_passed_update') ) }
        end
      else
        format.html { redirect_to(shopping_cart_items_url(), :notice => I18n.t('item_failed_update') ) }
      end
    end
  end
## TODO
  ## This method moves saved_cart_items to your shopping_cart_items or saved_cart_items
  #   this method is called using AJAX and returns json. with the object moved,
  #   otherwise false is returned if there is an error
  #   method => PUT
  def move_to
      @cart_item = session_cart.cart_items.find(params[:id])

      respond_to do |format|
        if @cart_item.update_attributes(:item_type_id => params[:item_type_id])
          format.html { redirect_to(shopping_cart_items_url() ) }
        else
          format.html { redirect_to(shopping_cart_items_url(), :notice => I18n.t('item_failed_update') ) }
        end
      end
  end

  # DELETE /carts/1
  # DELETE /carts/1.xml
  def destroy
    session_cart.remove_variant(params[:variant_id]) if params[:variant_id]
    redirect_to(shopping_cart_items_url)
  end

  private

  def get_new_cart_item
    if current_user
      session_cart.cart_items.new(params[:cart_item].merge({:user_id => current_user.id}))
    else
      ###  ADD to session cart
      session_cart.cart_items.new(params[:cart_item])
    end
  end

end
