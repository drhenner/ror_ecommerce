class Admin::Merchandise::Wizards::TaxStatusesController < Admin::Merchandise::Wizards::BaseController
  helper_method :selected?
  def index
    form_info
  end

  def create
    @tax_status = TaxStatus.new(params[:tax_status])
    if @tax_status.save
      session[:product_wizard] ||= {}
      session[:product_wizard][:tax_status_id] = @tax_status.id
      flash[:notice] = "Successfully created tax status."
      redirect_to next_form
    else
      form_info
      render :action => 'index'
    end
  end

  def update
    @tax_status = TaxStatus.find_by_id(params[:id])
    if @tax_status
      session[:product_wizard] ||= {}
      session[:product_wizard][:tax_status_id] = @tax_status.id
      flash[:notice] = "Successfully updated tax status."
      redirect_to next_form
    else
      form_info
      render :action => 'index'
    end
  end

  private

  def form_info
    @tax_statuses ||= TaxStatus.all
    @tax_status ||= TaxStatus.new
  end

  def selected?(id)
    session[:product_wizard][:tax_status_id] && session[:product_wizard][:tax_status_id] == id
  end
end
