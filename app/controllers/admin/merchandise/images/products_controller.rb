class Admin::Merchandise::Images::ProductsController < Admin::BaseController
  
  def edit
    @product  = Product.includes(:images).find(params[:id])
  end

  def update
    @product  = Product.find(params[:id])
    
    if @product.update_attributes(params[:product])
      redirect_to :action => :show
    else
      render :action => :edit
    end
  end
  
  def show
    @product = Product.includes(:images).find(params[:id])
  end

end
