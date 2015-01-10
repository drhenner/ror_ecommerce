class Admin::Config::ShippingCategoriesController < Admin::Config::BaseController
  # GET /admin/merchandise/shipping_categories
  def index
    @shipping_categories = ShippingCategory.all
  end

  # GET /admin/merchandise/shipping_categories/1
  def show
    @shipping_category = ShippingCategory.find(params[:id])
  end

  # GET /admin/merchandise/shipping_categories/new
  def new
    @shipping_category = ShippingCategory.new
  end

  # GET /admin/merchandise/shipping_categories/1/edit
  def edit
    @shipping_category = ShippingCategory.find(params[:id])
  end

  # POST /admin/merchandise/shipping_categories
  def create
    @shipping_category = ShippingCategory.new(allowed_params)

    if @shipping_category.save
      redirect_to(admin_config_shipping_rates_url(), notice: 'Shipping category was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /admin/merchandise/shipping_categories/1
  def update
    @shipping_category = ShippingCategory.find(params[:id])

    if @shipping_category.update_attributes(allowed_params)
      redirect_to(admin_config_shipping_rates_url(), notice: 'Shipping category was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /admin/merchandise/shipping_categories/1
  #def destroy
  #  @shipping_category = ShippingCategory.find(params[:id])
  # # @shipping_category.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to(admin_merchandise_shipping_categories_url) }
  #  end
  #end

  private

  def allowed_params
    params.require(:shipping_category).permit(:name)
  end
end
