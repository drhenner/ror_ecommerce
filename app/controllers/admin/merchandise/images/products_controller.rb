class Admin::Merchandise::Images::ProductsController < Admin::BaseController

  def edit
    @product  = Product.includes(:images).friendly.find(params[:id])
  end

  def update
    @product  = Product.friendly.find(params[:id])

    if @product.update_attributes(allowed_params)
      redirect_to action: :edit
    else
      render action: :edit
    end
  end

  def show
    @product = Product.friendly.includes(:images).find(params[:id])
  end
  private

  def allowed_params
    params.require(:product).permit!
  end

end
