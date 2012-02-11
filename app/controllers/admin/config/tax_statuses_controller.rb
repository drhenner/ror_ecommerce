class Admin::Config::TaxStatusesController < Admin::Config::BaseController
  # GET /tax_statuses
  # GET /tax_statuses.xml
  def index
    @tax_statuses = TaxStatus.all
  end

  # GET /tax_statuses/1
  def show
    @tax_status = TaxStatus.find(params[:id])
  end

  # GET /tax_statuses/new
  def new
    @tax_status = TaxStatus.new
  end

  # GET /tax_statuses/1/edit
  def edit
    @tax_status = TaxStatus.find(params[:id])
  end

  # POST /tax_statuses
  def create
    @tax_status = TaxStatus.new(params[:tax_status])

    respond_to do |format|
      if @tax_status.save
        format.html { redirect_to(admin_config_tax_statuses_url, :notice => 'Tax status was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /tax_statuses/1
  def update
    @tax_status = TaxStatus.find(params[:id])

    respond_to do |format|
      if @tax_status.update_attributes(params[:tax_status])
        format.html { redirect_to(admin_config_tax_statuses_url, :notice => 'Tax status was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /tax_statuses/1
  def destroy
    @tax_status = TaxStatus.find(params[:id])
    if @tax_status.products.empty?  && @tax_status.tax_rates.empty?
      @tax_status.destroy
    else
      flash[:alert] = "Sorry this Tax Status is already associated with a product or tax_rate.  You can not delete this Tax Status."
    end
    redirect_to(admin_config_tax_statuses_url)
  end
end
