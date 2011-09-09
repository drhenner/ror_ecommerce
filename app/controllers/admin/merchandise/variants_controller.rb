class Admin::Merchandise::VariantsController < Admin::BaseController

  respond_to :html, :json
  def index
    @product = Product.find(params[:product_id])
    @variants = @product.variants.admin_grid(@product, params)
    respond_to do |format|
      format.html
      format.json { render :json => @variants.to_jqgrid_json(
        [ :product_name, :sku, :price ],
        @variants.per_page, #params[:page],
        @variants.current_page, #params[:rows],
        @variants.total_entries)

      }
    end
  end

  def show
    @variant = Variant.includes(:product).find(params[:id])
    @product  =  @variant.product
    respond_with(@variant)
  end

  def new
    form_info
    @product = Product.find(params[:product_id])
    @variant = @product.variants.new()
  end

  def create
    @product = Product.find(params[:product_id])
    @variant = @product.variants.new(params[:variant])

    if @variant.save
      redirect_to admin_merchandise_product_variants_url(@product)
    else
      form_info
      flash[:error] = "The variant could not be saved"
      render :action => :new
    end
  end

  def edit
    @variant  = Variant.includes(:properties,:variant_properties, {:product => :properties}).find(params[:id])
    @product  =  @variant.product
    form_info
  end

  def update
    @variant = Variant.includes( :product ).find(params[:id])

    if @variant.update_attributes(params[:variant])
      redirect_to admin_merchandise_product_variants_url(@variant.product)
    else
      form_info
      @product  =  @variant.product
      render :action => :edit
    end
  end

  def destroy
    @variant = Variant.find(params[:id])
    @variant.active = false
    @variant.save

    redirect_to :action => :index
  end

  private

    def form_info
      @brands = Brand.all.collect{|b| [b.name, b.id] }
      #@prototypes = Prototype.all.collect{|pt| [pt.name, pt.id]}
      #@all_properties = Property.all
      #@select_variant_types = VariantType.all.collect{|pt| [pt.name, pt.id]}
      #@select_shipping_category = ShippingCategory.all.collect {|sc| [sc.name, sc.id]}
    end
end
