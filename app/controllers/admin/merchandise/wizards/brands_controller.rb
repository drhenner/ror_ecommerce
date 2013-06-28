class Admin::Merchandise::Wizards::BrandsController < Admin::Merchandise::Wizards::BaseController
  helper_method :selected?
  def index
    form_info
    session[:product_wizard] ||= {}
  end

  def create
    @brand = Brand.new(allowed_params)
    if @brand.save
      session[:product_wizard] ||= {}
      session[:product_wizard][:brand_id] = @brand.id
      flash[:notice] = "Successfully created brand."
      redirect_to next_form
    else
      form_info
      render :action => 'index'
    end
  end

  def update
    @brand = Brand.find_by_id(params[:id])
    if @brand
      session[:product_wizard] ||= {}
      session[:product_wizard][:brand_id] = @brand.id
      flash[:notice] = "Successfully added brand."
      redirect_to next_form
    else
      form_info
      render :action => 'index'
    end
  end

  private

  def allowed_params
    params.require(:brand).permit(:name)
  end

  def form_info
    @brands ||= Brand.all
    @brand ||= Brand.new
  end

  def selected?(id)
    session[:product_wizard][:brand_id] && session[:product_wizard][:brand_id] == id
  end
end
