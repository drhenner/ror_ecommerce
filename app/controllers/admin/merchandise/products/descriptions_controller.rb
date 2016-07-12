class Admin::Merchandise::Products::DescriptionsController < Admin::BaseController
  def edit
    @product = Product.friendly.find(params[:id])
  end

  def update
    @product = Product.friendly.find(params[:id])
    if @product.update_attributes(allowed_params)
      redirect_to admin_merchandise_product_url(@product)
    else
      render :action => :edit
    end
  end
  private

  def allowed_params
    params.require(:product).permit(:name, :description_markup)
  end
end
