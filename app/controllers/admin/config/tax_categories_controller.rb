class Admin::Config::TaxCategoriesController < Admin::Config::BaseController
  # GET /tax_categories
  # GET /tax_categories.xml
  def index
    @tax_categories = TaxCategory.all
  end

  # GET /tax_categories/1
  def show
    @tax_category = TaxCategory.find(params[:id])
  end

  # GET /tax_categories/new
  def new
    @tax_category = TaxCategory.new
  end

  # GET /tax_categories/1/edit
  def edit
    @tax_category = TaxCategory.find(params[:id])
  end

  # POST /tax_categories
  def create
    @tax_category = TaxCategory.new(params[:tax_category])

    respond_to do |format|
      if @tax_category.save
        format.html { redirect_to(admin_config_tax_categories_url, :notice => 'Tax status was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /tax_categories/1
  def update
    @tax_category = TaxCategory.find(params[:id])

    respond_to do |format|
      if @tax_category.update_attributes(params[:tax_category])
        format.html { redirect_to(admin_config_tax_categories_url, :notice => 'Tax status was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /tax_categories/1
  def destroy
    @tax_category = TaxCategory.find(params[:id])
    if @tax_category.products.empty?  && @tax_category.tax_rates.empty?
      @tax_category.destroy
    else
      flash[:alert] = "Sorry this Tax Status is already associated with a product or tax_rate.  You can not delete this Tax Status."
    end
    redirect_to(admin_config_tax_categories_url)
  end
end
