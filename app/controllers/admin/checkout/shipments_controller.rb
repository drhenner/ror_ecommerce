class Admin::Checkout::ShipmentsController < Admin::Checkout::BaseController
  # GET /shipments
  # GET /shipments.xml
  def index
    @shipments = Shipment.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /shipments/1
  # GET /shipments/1.xml
  def show
    @shipment = Shipment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /shipments/new
  # GET /shipments/new.xml
  def new
    @shipment = Shipment.new
    form_info
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /shipments/1/edit
  def edit
    @shipment = Shipment.find(params[:id])
    form_info
  end

  # POST /shipments
  # POST /shipments.xml
  def create
    @shipment = Shipment.new(params[:shipment])

    respond_to do |format|
      if @shipment.save
        format.html { redirect_to(admin_checkout_shipment_url(@shipment), :notice => 'Shipment was successfully created.') }
      else
        form_info
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /shipments/1
  # PUT /shipments/1.xml
  def update
    @shipment = Shipment.find(params[:id])

    respond_to do |format|
      if @shipment.update_attributes(params[:shipment])
        format.html { redirect_to(admin_checkout_shipment_url(@shipment), :notice => 'Shipment was successfully updated.') }
      else
        form_info
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /shipments/1
  # DELETE /shipments/1.xml
  def destroy
    @shipment = Shipment.find(params[:id])
    @shipment.update_attributes(:active => false)

    respond_to do |format|
      format.html { redirect_to(admin_checkout_shipments_url) }
    end
  end
  
  private
  
  def form_info
    
  end
  
end
