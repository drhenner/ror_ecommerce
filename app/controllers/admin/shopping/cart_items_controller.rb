class Admin::Shopping::CartItemsController < Admin::Shopping::BaseController
  def update
    @cart_item = session_admin_cart.shopping_cart_items.find_by(id: params[:id])

    unless @cart_item
      head :not_found
      return
    end

    session_admin_cart.set_cart_item_quantity(@cart_item.id, params[:quantity].to_i)
    session_admin_cart.reload

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_shopping_products_url }
    end
  end

  def destroy
    @cart_item = session_admin_cart.shopping_cart_items.find_by(id: params[:id])
    @cart_item&.inactivate!
    session_admin_cart.reload

    respond_to do |format|
      format.turbo_stream { render :update }
      format.html { redirect_to admin_shopping_products_url }
    end
  end
end
