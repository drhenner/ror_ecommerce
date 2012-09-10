class Admin::Merchandise::Products::DescriptionsController < Admin::BaseController
  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      redirect_to admin_merchandise_product_url(@product)
    else
      render :action => :edit
    end
  end
end
