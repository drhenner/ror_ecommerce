class Admin::Merchandise::Wizards::BaseController < Admin::BaseController
  helper_method :next_wizard_form

private
  def next_form
    if next_wizard_form
      next_wizard_form
    else
      new_admin_merchandise_wizards_product_url
    end
  end

  def next_wizard_form
    if !session[:product_wizard]
      reset_product_wizard
      admin_merchandise_wizards_brands_url
    elsif !session[:product_wizard][:brand_id]
      admin_merchandise_wizards_brands_url
    elsif !session[:product_wizard][:product_type_id]
      admin_merchandise_wizards_product_types_url
    elsif !session[:product_wizard][:property_ids]
      admin_merchandise_wizards_properties_url
    elsif !session[:product_wizard][:shipping_category_id]
      admin_merchandise_wizards_shipping_categories_url
    else
      nil
    end
  end

  def reset_product_wizard
    session[:product_wizard] = {}
  end
end
