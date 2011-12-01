class Admin::Merchandise::Wizards::PrototypesController < Admin::Merchandise::Wizards::BaseController
  def update
    if @prototype = Prototype.find_by_id(params[:id])
      session[:product_wizard] ||= {}
      session[:product_wizard][:property_ids] = @prototype.property_ids
      flash[:notice] = "Successfully added."
    end
    redirect_to next_form
  end

end
