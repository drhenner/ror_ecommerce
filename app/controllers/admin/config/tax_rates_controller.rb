class Admin::Config::TaxRatesController < Admin::Config::BaseController
  # GET /tax_rates
  # GET /tax_rates.xml
  def index
    @tax_rates = TaxRate.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /tax_rates/1
  # GET /tax_rates/1.xml
  def show
    @tax_rate = TaxRate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /tax_rates/new
  # GET /tax_rates/new.xml
  def new
    @tax_rate = TaxRate.new
    form_info
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /tax_rates/1/edit
  def edit
    @tax_rate = TaxRate.find(params[:id])
    form_info
  end

  # POST /tax_rates
  # POST /tax_rates.xml
  def create
    @tax_rate = TaxRate.new(params[:tax_rate])

    respond_to do |format|
      if @tax_rate.save
        format.html { redirect_to(admin_config_tax_rate_url(@tax_rate), :notice => 'Tax rate was successfully created.') }
      else
        form_info
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /tax_rates/1
  # PUT /tax_rates/1.xml
  def update
    @tax_rate = TaxRate.find(params[:id])

    respond_to do |format|
      if @tax_rate.update_attributes(params[:tax_rate])
        format.html { redirect_to(admin_config_tax_rate_url(@tax_rate), :notice => 'Tax rate was successfully updated.') }
      else
        form_info
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /tax_rates/1
  # DELETE /tax_rates/1.xml
  def destroy
    @tax_rate = TaxRate.find(params[:id])
    @tax_rate.update_attributes(:active => false)

    respond_to do |format|
      format.html { redirect_to(admin_config_tax_rates_url) }
    end
  end
  private
  
  def form_info
    @states = State.form_selector
    @tax_statuses = TaxStatus.all.collect{|pt| [ pt.name, pt.id] }
  end
end
