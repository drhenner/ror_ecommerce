class Admin::Merchandise::Changes::PropertiesController < Admin::BaseController
  helper_method :all_properties
  before_filter :get_product
  def edit
    form_info
  end

  def update
    if @product.update_attributes(params[:product])
      flash[:notice] = "Successfully updated properties."
      redirect_to admin_merchandise_product_url(@product.id)
    else
      form_info
      render :action => 'edit'
    end
  end

  private
  def all_properties
     @all_properties ||= Property.all.map{|p| [ p.identifing_name, p.id ]}
  end

  def get_product
    @product = Product.find_by_id(params[:product_id])
  end

  def form_info

  end
end
