class Admin::Fulfillment::ShipmentsController < Admin::Fulfillment::BaseController
  # GET /admin/fulfillment/shipments
  # GET /admin/fulfillment/shipments.xml
  def index
    @shipments = Shipment.includes([:order, {:order_items => {:variant => :product} }])
    if params[:order_id].present?
      @shipments = @shipments.where(['shipments.order_id = ?', params[:order_id]])
      @order = Order.find(params[:order_id])
    end
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/fulfillment/shipments/1
  # GET /admin/fulfillment/shipments/1.xml
  def show
    @shipment = Shipment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/fulfillment/shipments/new
  # GET /admin/fulfillment/shipments/new.xml
  def new
    @shipment = Shipment.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/fulfillment/shipments/1/edit
  def edit
    @shipment = Shipment.find(params[:id])
  end

  # POST /admin/fulfillment/shipments
  # POST /admin/fulfillment/shipments.xml
  def create
    @shipment = Shipment.new(params[:shipment])

    respond_to do |format|
      if @shipment.save
        format.html { redirect_to(admin_fulfillment_shipments_path(@shipment, :order_id => @shipment.order_id), :notice => 'Shipment was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/fulfillment/shipments/1
  # PUT /admin/fulfillment/shipments/1.xml
  def update
    @shipment = Shipment.find(params[:id])

    respond_to do |format|
      if @shipment.update_attributes(params[:shipment])
        format.html { redirect_to(admin_fulfillment_shipments_path(@shipment, :order_id => @shipment.order_id), :notice => 'Shipment was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # PUT /admin/fulfillment/shipments/1
  # PUT /admin/fulfillment/shipments/1.xml
  def ship
    load_info
    @shipment = Shipment.includes({:order_items => :variant}).find(params[:id])

    respond_to do |format|
      if @shipment.ship!
        format.html { redirect_to(admin_fulfillment_shipments_path(@shipment, :order_id => @shipment.order_id), :notice => 'Shipment was successfully updated.') }
      else
        format.html { redirect_to(admin_fulfillment_shipments_path(@shipment, :order_id => @shipment.order_id), :error => 'Shipment could not be shipped!!!') }
      end
    end
  end

  # DELETE /admin/fulfillment/shipments/1
  # DELETE /admin/fulfillment/shipments/1.xml
  def destroy
    @shipment = Shipment.find(params[:id])
    raise error
    @shipment.update_attributes(:active => false)
    
    
    # We need to add capability to refund and return to stock in one large destroy form

    respond_to do |format|
      format.html { redirect_to(admin_fulfillment_shipments_url( :order_id => (@shipment.order_id)) ) }
    end
  end
  
  private
  
  def load_info
    @order = Order.includes([:shipments, {:order_items => [:shipment, {:variant => :product}]}]).find(params[:order_id])
  end
  
  def form_info
    
  end
  
end
