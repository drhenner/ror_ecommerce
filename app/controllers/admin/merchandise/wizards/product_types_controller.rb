class Admin::Merchandise::Wizards::ProductTypesController < Admin::Merchandise::Wizards::BaseController
  helper_method :selected?
  def index
    form_info
  end

  def create
    product_type = ProductType.new(allowed_params)

    flash[:notice] = "Successfully created product type." if product_type.save
    form_info
    render :action => 'index'
  end

  def update
    @product_type = ProductType.find_by_id(params[:id])
    if @product_type
      session[:product_wizard] ||= {}
      session[:product_wizard][:product_type_id] = @product_type.id
      flash[:notice] = "Successfully added product type."
      redirect_to next_form
    else
      form_info
      render :action => 'index'
    end
  end

  private

  def allowed_params
    params.require(:product_type).permit(:name, :parent_id)
  end

  def form_info
    @product_types ||= ProductType.all
    @product_type ||= ProductType.new
  end

  def selected?(id)
    session[:product_wizard][:product_type_id] && session[:product_wizard][:product_type_id] == id
  end
end
