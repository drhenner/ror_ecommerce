class Admin::Fulfillment::AddressesController < Admin::Fulfillment::BaseController
  # GET /admin/fulfillment/addresses
  # GET /admin/fulfillment/addresses.xml
  #def index
  #  load_info
  #  @addresses  = @shipment.shipping_addresses
  #  @address    = @shipment.address
  #
  #  respond_to do |format|
  #    format.html # index.html.erb
  #  end
  #end

  # GET /admin/fulfillment/addresses/1/edit
  def edit
    load_info
    @addresses  = @shipment.shipping_addresses
    @address = Address.find(params[:id])
  end

  # PUT /admin/fulfillment/addresses/1
  def update
    load_info
    @address = Address.find(params[:id])

    @shipment.address = @address
    @shipment.save
    redirect_to(admin_fulfillment_shipments_path(:order_id => @shipment.order_id), :notice => 'Shipping address was successfully selected.')

  end

  private

  def load_info
    @shipment = Shipment.find_fulfillment_shipment(params[:shipment_id])
  end

end
