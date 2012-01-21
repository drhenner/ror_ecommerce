class Admin::Config::ShippingCategoriesController < Admin::Config::BaseController
  # GET /admin/merchandise/shipping_categories
  def index
    @shipping_categories = ShippingCategory.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/merchandise/shipping_categories/1
  def show
    @shipping_category = ShippingCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/merchandise/shipping_categories/new
  def new
    form_info
    @shipping_category = ShippingCategory.new

      respond_to do |format|
        format.html # new.html.erb
      end
  end

  # GET /admin/merchandise/shipping_categories/1/edit
  def edit
    form_info
    @shipping_category = ShippingCategory.find(params[:id])
  end

  # POST /admin/merchandise/shipping_categories
  def create
    @shipping_category = ShippingCategory.new(params[:shipping_category])

    respond_to do |format|
      if @shipping_category.save
        format.html { redirect_to(admin_config_shipping_rates_url(), :notice => 'Shipping category was successfully created.') }
      else
        form_info
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/merchandise/shipping_categories/1
  def update
    @shipping_category = ShippingCategory.find(params[:id])

    respond_to do |format|
      if @shipping_category.update_attributes(params[:shipping_category])
        format.html { redirect_to(admin_config_shipping_rates_url(), :notice => 'Shipping category was successfully updated.') }
      else
        form_info
        format.html { render :action => "edit" }
      end
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

  def form_info

  end
end
