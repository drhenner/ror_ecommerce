class ProductsController < ApplicationController
  
  def create
    
    pagination_args = {}
    pagination_args[:page] = params[:page] || 1
    pagination_args[:rows] = params[:rows] || 15
    
    if params[:q] && params[:q].present?
      @products = Product.standard_search(params[:q], pagination_args).results
    else
      @products = Product.where('deleted_at IS NULL OR deleted_at > ?', Time.zone.now )
    end

    render :template => '/products/index'
  end
  
  def show
    @product = Product.find(params[:id])
    form_info
  end
  
  private
  
  def form_info
    @cart_item = CartItem.new
  end
end
