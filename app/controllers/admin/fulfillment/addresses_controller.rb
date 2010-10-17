class Admin::Fulfillment::AddressesController < Admin::Fulfillment::BaseController
  # GET /admin/fulfillment/addresses
  # GET /admin/fulfillment/addresses.xml
  def index
    load_info
    @addresses  = @shipment.order.user.shipping_addresses
    @address    = @shipment.address

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/fulfillment/addresses/1
  # GET /admin/fulfillment/addresses/1.xml
  def show
    load_info
    @address = Address.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/fulfillment/addresses/new
  # GET /admin/fulfillment/addresses/new.xml
  def new
    load_info
    @address = Address.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/fulfillment/addresses/1/edit
  def edit
    load_info
    @addresses  = @shipment.order.user.shipping_addresses
    @address = Address.find(params[:id])
  end

  # POST /admin/fulfillment/addresses
  # POST /admin/fulfillment/addresses.xml
  def create
    load_info
    @address = Address.new(params[:address])

    respond_to do |format|
      if @address.save
        format.html { redirect_to(admin_fulfillment_shipment_address_path(@shipment, @address), :notice => 'Address was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /admin/fulfillment/addresses/1
  # PUT /admin/fulfillment/addresses/1.xml
  def update
    load_info
    @address = Address.find(params[:id])

    @shipment.update_attributes(:address => @address)
    redirect_to(admin_fulfillment_shipments_path(:order_id => @shipment.order_id), :notice => 'Shipping address was successfully selected.')

  end
  
  private
  
  def load_info
    @shipment = Shipment.includes([{:order => {:user => :shipping_addresses}} , :address ]).find(params[:shipment_id])
  end

end
