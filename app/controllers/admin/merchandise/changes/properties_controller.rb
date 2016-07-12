class Admin::Merchandise::Changes::PropertiesController < Admin::BaseController
  helper_method :all_properties
  before_action :get_product
  def edit
    #@product.product_properties.build
  end

  def update
    if @product.update_attributes(allowed_params)
      flash[:notice] = "Successfully updated properties."
      redirect_to admin_merchandise_product_url(@product.id)
    else
      render :action => 'edit'
    end
  end

  private

  def allowed_params
    params.require(:product).permit!
  end

  def all_properties
     @all_properties ||= Property.all.map{|p| [ p.identifing_name, p.id ]}
  end

  def get_product
    @product = Product.friendly.find_by(id: params[:product_id])
  end

end
