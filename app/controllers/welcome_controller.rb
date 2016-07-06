class WelcomeController < ApplicationController
  layout 'welcome'

  def index
    @featured_product = Product.featured
    @best_selling_products = Product.limit(5)
    @other_products  ## search 2 or 3 categories (maybe based on the user)
    unless @featured_product
      if current_user && current_user.admin?
        redirect_to admin_merchandise_products_url
      else
        redirect_to login_url
      end
    end
  end
end
