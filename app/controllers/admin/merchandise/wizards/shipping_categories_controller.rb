class Admin::Merchandise::Wizards::ShippingCategoriesController < Admin::Merchandise::Wizards::BaseController
  helper_method :selected?
  def index
    form_info
  end

  def create
    @shipping_category = ShippingCategory.new(allowed_params)
    if @shipping_category.save
      session[:product_wizard] ||= {}
      session[:product_wizard][:shipping_category_id] = @shipping_category.id
      flash[:notice] = "Successfully created shipping category."
      redirect_to next_form
    else
      form_info
      render :action => 'index'
    end
  end

  def update
    @shipping_category = ShippingCategory.find_by_id(params[:id])
    if @shipping_category
      session[:product_wizard] ||= {}
      session[:product_wizard][:shipping_category_id] = @shipping_category.id
      flash[:notice] = "Successfully updated shipping category."
      redirect_to next_form
    else
      form_info
      render :action => 'index'
    end
  end

  private

  def allowed_params
    params.require(:shipping_category).permit(:name)
  end

  def form_info
    @shipping_categories ||= ShippingCategory.all
    @shipping_category ||= ShippingCategory.new
  end

  def selected?(id)
    (session[:product_wizard][:shipping_category_id] && session[:product_wizard][:shipping_category_id] == id) ? 'selected' : ''
  end
end
