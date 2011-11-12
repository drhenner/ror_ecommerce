class Admin::Shopping::ProductsController < Admin::Shopping::BaseController
  # GET /admin/order/products
  def index
    @products = Product.admin_grid(params, true)
    respond_to do |format|
      format.html
      format.json { render :json => @products.to_jqgrid_json(
        [ :name, :display_price_range ],
        @products.per_page, #params[:page],
        @products.current_page, #params[:rows],
        @products.total_entries)

      }
    end
  end

  # GET /admin/order/products/1
  # GET /admin/order/products/1.xml
  def show
    @product = Product.includes({:variants => {:variant_properties => :property} }).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def edit
    @product = Product.includes({:variants => {:variant_properties => :property} }).find(params[:id])
  end

  # PUT /admin/order/products/1
  def update
    #@product = Product.find(params[:id])
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

 # def tax_percentage(tax_rate)
 #   tax_rate ? tax_rate.rate : 0
 # end
end
