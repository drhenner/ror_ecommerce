class Admin::Merchandise::Multi::VariantsController < Admin::BaseController
  def edit
    @product        = Product.includes(:properties,:product_properties, {:prototype => :properties}).find(params[:product_id])
    form_info
    render :layout => 'admin_markup'
  end

  def update
    @product = Product.find(params[:product_id])

    if @product.update_attributes(params[:product])
      flash[:notice] = "Successfully updated variants"
      redirect_to admin_merchandise_product_url(@product)
    else
      form_info
      render :action => :edit, :layout => 'admin_markup'
    end
  end
  private

  def form_info
    @brands = Brand.all.collect{|b| [b.name, b.id] }
  end
end