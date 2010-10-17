class Admin::Shopping::ProductsController < Admin::Shopping::BaseController
  # GET /admin/order/products
  # GET /admin/order/products.xml
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
      format.xml  { render :xml => @admin_shopping_product }
    end
  end

  # GET /admin/order/products/new
  # GET /admin/order/products/new.xml
#  def new
#    @admin_shopping_product = Product.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @admin_shopping_product }
#    end
#  end
#
#  # GET /admin/order/products/1/edit
  def edit
    @product = Product.includes({:variants => {:variant_properties => :property} }).find(params[:id])
  end
#
#  # POST /admin/order/products
#  # POST /admin/order/products.xml
#  def create
#    @product = Product.new(params[:product])
#
#    respond_to do |format|
#      if @product.save
#        format.html { redirect_to(@admin_shopping_product, :notice => 'Product was successfully created.') }
#      else
#        format.html { render :action => "new" }
#      end
#    end
#  end

  # PUT /admin/order/products/1
  # PUT /admin/order/products/1.xml
  def update
    #@product = Product.find(params[:id])
    params[:variant].each_pair do |variant_id, qty|
        if (qty.first.blank? || (!qty.first.blank? && qty.first.to_i == 0))
          session_admin_cart[:order_items].delete(variant_id)
        else
          variant = Variant.find(variant_id)
          tax_rate = nil
          tax_rate = variant.product_tax_rate(session_admin_cart[:shipping_address].state_id, Time.now) if session_admin_cart[:shipping_address]
          session_admin_cart[:order_items][variant_id] = { :variant  => variant, 
                                                        :quantity => qty.to_i,
                                                        :tax_rate => tax_rate,
                                                        :price    => variant.price,
                                                        :total    => ((1 + tax_percentage(tax_rate)) * variant.price),
                                                        :shipping_rate => nil } 
          # order_items => {variant_id, price, total, tax_rate, shipping_rate}
        end
    end
    respond_to do |format|
      format.html { redirect_to(admin_shopping_products_url, :notice => 'Successfully added.  Ask the customer if they would like anything else.') }
    end
  end

  private
  
  def tax_percentage(tax_rate)
    tax_rate ? tax_rate.rate : 0
  end
end
