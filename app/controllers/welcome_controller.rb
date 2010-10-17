class WelcomeController < ApplicationController
  
  def index
    @featured_product = Product.featured
    @best_selling_products = Product.limit(4)
    @other_products  ## search 2 or 3 categories (maybe based on the user)
    #redirect_to admin_merchandise_products_url unless @featured_product
  end
end
