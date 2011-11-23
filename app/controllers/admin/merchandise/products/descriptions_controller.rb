class Admin::Merchandise::Products::DescriptionsController < ApplicationController
  #layout 'mercury'
  layout 'admin_markup'

  def edit
    form_info
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      redirect_to admin_merchandise_product_url(@product)
    else
      form_info
      render :action => :edit, :layout => 'admin_markup'
    end
  end

  private

  def form_info

  end
end
