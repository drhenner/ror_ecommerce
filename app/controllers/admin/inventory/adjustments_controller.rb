class Admin::Inventory::AdjustmentsController < Admin::BaseController
  def show
    @product = Product.friendly.includes(:variants).find(params[:id])
  end

  def index
    @products = Product.paginate(:page => pagination_page, :per_page => pagination_rows)
  end

  def edit
    @variant = Variant.includes(:product).find(params[:id])
  end

  def update
    @variant = Variant.find(params[:id])
    ###  the reason will effect accounting
    #    if the item is refunded by the supplier the accounting will be reflected
    if params[:refund].present? && params[:variant][:qty_to_add].present?
      if params[:refund].to_f > 0.0
        AccountingAdjustment.adjust_stock(@variant.inventory, params[:variant][:qty_to_add].to_i, params[:refund].to_f)
        flash[:notice] = "Successfully updated the inventory."
        redirect_to admin_inventory_adjustment_url(@variant.product)
      elsif @variant.update_attributes(allowed_params)
        flash[:notice] = "Successfully updated the inventory."
        redirect_to admin_inventory_adjustment_url(@variant.product)
      else
        render :action => 'edit', :id => params[:id]
      end
    else
      flash[:alert] = "Refund must be entered (fill in 0 for no refund)." unless params[:refund].present?
      render :action => 'edit', :id => params[:id]
    end
  end

  private

  def allowed_params
    params.require(:variant).permit(:qty_to_add)
  end

end

