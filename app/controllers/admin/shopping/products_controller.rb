class Admin::Shopping::ProductsController < Admin::Shopping::BaseController
  helper_method :sort_column, :sort_direction, :product_types

  # GET /admin/order/products
  def index
    @products = Product.admin_grid(params, true).order(sort_column + " " + sort_direction).
                                              paginate(:page => pagination_page, :per_page => pagination_rows)
  end

  # GET /admin/order/products/1
  # GET /admin/order/products/1.xml
  def show
    @product = Product.friendly.includes({:variants => {:variant_properties => :property} }).find(params[:id])
  end

  def edit
    @product = Product.friendly.includes({:variants => {:variant_properties => :property} }).find(params[:id])
  end

  # PUT /admin/order/products/1
  def update
    params[:variant].each_pair do |variant_id, qty|
      if (qty.first.blank? || (!qty.first.blank? && qty.first.to_i == 0))
        session_admin_cart.remove_variant(variant_id)
      else
        session_admin_cart.add_variant(variant_id, session_admin_cart.customer, qty, ItemType::SHOPPING_CART_ID, true)
      end
    end
    respond_to do |format|
      format.html { redirect_to(admin_shopping_products_url, :notice => 'Successfully added.  Ask the customer if they would like anything else.') }
    end
  end

  private

  def product_types
    @product_types ||= ProductType.all
  end
  def sort_column
    Product.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
 # def tax_percentage(tax_rate)
 #   tax_rate ? tax_rate.rate : 0
 # end
end
