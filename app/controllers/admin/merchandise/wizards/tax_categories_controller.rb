class Admin::Merchandise::Wizards::TaxCategoriesController < Admin::Merchandise::Wizards::BaseController
  helper_method :selected?
  def index
    form_info
  end

  def create
    @tax_category = TaxCategory.new(params[:tax_category])
    if @tax_category.save
      session[:product_wizard] ||= {}
      session[:product_wizard][:tax_category_id] = @tax_category.id
      flash[:notice] = "Successfully created tax Category."
      redirect_to next_form
    else
      form_info
      render :action => 'index'
    end
  end

  def update
    @tax_category = TaxCategory.find_by_id(params[:id])
    if @tax_category
      session[:product_wizard] ||= {}
      session[:product_wizard][:tax_category_id] = @tax_category.id
      flash[:notice] = "Successfully updated tax Category."
      redirect_to next_form
    else
      form_info
      render :action => 'index'
    end
  end

  private

  def form_info
    @tax_categories ||= TaxCategory.all
    @tax_category ||= TaxCategory.new
  end

  def selected?(id)
    session[:product_wizard][:tax_category_id] && session[:product_wizard][:tax_category_id] == id
  end
end
