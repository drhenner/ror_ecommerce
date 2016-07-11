class Admin::Merchandise::ProductsController < Admin::BaseController
  helper_method :sort_column, :sort_direction, :product_types
  authorize_resource

  def index
    params[:page] ||= 1
    @products = Product.admin_grid(params).order(sort_column + " " + sort_direction).
                                              paginate(page: pagination_page, per_page: pagination_rows)
  end

  def show
    @product        = Product.friendly.find(params[:id])
    @shipping_zones =  ShippingZone.all
    respond_to do |format|
      format.html
      format.json { render json: @product }
    end
  end

  def new
    form_info
    if @prototypes.empty?
      flash[:notice] = "You must create a prototype before you create a product."
      redirect_to new_admin_merchandise_prototype_url
    else
      @product            = Product.new
      @product.prototype  = Prototype.new
    end
  end

  def create
    @product = Product.new(allowed_params)

    if @product.save
      flash[:notice] = "Success, You should create a variant for the product."
      redirect_to edit_admin_merchandise_products_description_url(@product)
    else
      form_info
      flash[:error] = "The product could not be saved"
      render action: :new
    end
  rescue
    render :text => "Please make sure you have solr started... Run this in the command line => bundle exec rake sunspot:solr:start"
  end

  def edit
    @product        = Product.friendly.includes(:properties,:product_properties, {:prototype => :properties}).find(params[:id])
    form_info
  end

  def update
    @product = Product.friendly.find(params[:id])

    if @product.update_attributes(allowed_params)
      redirect_to admin_merchandise_product_url(@product)
    else
      form_info
      render action: :edit#, :layout => 'admin_markup'
    end
  end

  def add_properties
    prototype  = Prototype.friendly.includes(:properties).find(params[:id])
    @properties = prototype.properties
    all_properties = Property.all

    @properties_hash = all_properties.inject({:active => [], :inactive => []}) do |h, property|
      if  @properties.detect{|p| (p.id == property.id) }
        h[:active] << property.id
      else
        h[:inactive] << property.id
      end
      h
    end
    respond_to do |format|
      format.html
      format.json { render json: @properties_hash.to_json }
    end
  end

  def activate
    @product = Product.friendly.find(params[:id])
    @product.deleted_at = nil
    if @product.save
      redirect_to admin_merchandise_product_url(@product)
    else
      if @product.description.blank?
        flash[:alert] = "Please add a description before Activating."
      else
        flash[:alert] = @product.errors.full_messages.join('  ')
      end
      redirect_to edit_admin_merchandise_products_description_url(@product)
    end
  end

  def destroy
    @product = Product.friendly.find(params[:id])
    @product.deleted_at ||= Time.zone.now
    @product.save

    redirect_to admin_merchandise_product_url(@product)
  end

  private

    def allowed_params
      params.require(:product).permit(:name, :description, :product_keywords, :set_keywords, :product_type_id,
                                      :prototype_id, :shipping_category_id, :permalink, :available_at, :deleted_at,
                                      :meta_keywords, :meta_description, :featured, :description_markup, :brand_id,
                                      product_properties_attributes: [:id, :product_id, :property_id, :position, :description])
    end

    def form_info
      @prototypes               = Prototype.all.map{|pt| [pt.name, pt.id]}
      @all_properties           = Property.all
      @select_shipping_category = ShippingCategory.all.map {|sc| [sc.name, sc.id]}
      @brands                   = Brand.order(:name).map {|ts| [ts.name, ts.id]}
    end

    def product_types
      @product_types ||= ProductType.all
    end

    def sort_column
      Product.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

end
