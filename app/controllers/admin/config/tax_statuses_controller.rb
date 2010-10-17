class Admin::Config::TaxStatusesController < Admin::Config::BaseController
  # GET /tax_statuses
  # GET /tax_statuses.xml
  def index
    @tax_statuses = TaxStatus.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tax_statuses }
    end
  end

  # GET /tax_statuses/1
  # GET /tax_statuses/1.xml
  def show
    @tax_status = TaxStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tax_status }
    end
  end

  # GET /tax_statuses/new
  # GET /tax_statuses/new.xml
  def new
    @tax_status = TaxStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tax_status }
    end
  end

  # GET /tax_statuses/1/edit
  def edit
    @tax_status = TaxStatus.find(params[:id])
  end

  # POST /tax_statuses
  # POST /tax_statuses.xml
  def create
    @tax_status = TaxStatus.new(params[:tax_status])

    respond_to do |format|
      if @tax_status.save
        format.html { redirect_to(@tax_status, :notice => 'Tax status was successfully created.') }
        format.xml  { render :xml => @tax_status, :status => :created, :location => @tax_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tax_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tax_statuses/1
  # PUT /tax_statuses/1.xml
  def update
    @tax_status = TaxStatus.find(params[:id])

    respond_to do |format|
      if @tax_status.update_attributes(params[:tax_status])
        format.html { redirect_to(@tax_status, :notice => 'Tax status was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tax_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tax_statuses/1
  # DELETE /tax_statuses/1.xml
  def destroy
    @tax_status = TaxStatus.find(params[:id])
    @tax_status.destroy

    respond_to do |format|
      format.html { redirect_to(tax_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
