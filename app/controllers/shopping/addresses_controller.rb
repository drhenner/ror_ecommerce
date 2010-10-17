class Shopping::AddressesController < Shopping::BaseController
  # GET /shopping/addresses
  # GET /shopping/addresses.xml
  def index
    @shopping_address = Address.new
    form_info
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shopping_addresses }
    end
  end

  # GET /shopping/addresses/1
  # GET /shopping/addresses/1.xml
#  def show
#    @shopping_address = Address.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @shopping_address }
#    end
#  end

  # GET /shopping/addresses/new
  # GET /shopping/addresses/new.xml
#  def new
#    @shopping_address = Address.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @shopping_address }
#    end
#  end

  # GET /shopping/addresses/1/edit
  def edit
    @shopping_address = Address.find(params[:id])
  end

  # POST /shopping/addresses
  # POST /shopping/addresses.xml
  def create
    if params[:address].present?
      @shopping_address = current_user.addresses.new(params[:address])
      @shopping_address.default = true          if current_user.default_shipping_address.nil?
      @shopping_address.billing_default = true  if current_user.default_billing_address.nil?
      @shopping_address.save
    elsif params[:shopping_address_id].present?
      @shopping_address = Address.find(params[:shopping_address_id])
    end
    respond_to do |format|
      
      if @shopping_address.id
        update_order_address_id(@shopping_address.id)
        format.html { redirect_to(shopping_orders_url, :notice => 'Address was successfully created.') }
        format.xml  { render :xml => @shopping_address, :status => :created, :location => @shopping_address }
      else
        form_info
        format.html { render :action => "index" }
        format.xml  { render :xml => @shopping_address.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shopping/addresses/1
  # PUT /shopping/addresses/1.xml
  def update
    #old_address = current_user.addresses.find(params[:id])
    #Address.update_address(old_address, params[:shopping_address], AddressType::SHIPPING_ID, find_or_create_order )
    @shopping_address = current_user.addresses.new(params[:address])
    
    # if we are editing the current default address then this is the default address
    @shopping_address.default = true if params[:id] == current_user.default_shipping_address.try(:id)
    
    respond_to do |format|
      if @shopping_address.valid? && @shopping_address.save_default_address
        old_shopping_address = current_user.addresses.find(params[:id])
        old_shopping_address.update_attributes(:active => false)
        update_order_address_id(@shopping_address.id)
        format.html { redirect_to(shopping_orders_url, :notice => 'Address was successfully updated.') }
        format.xml  { head :ok }
      else
        @shopping_address.update_attributes(params[:address])
        @states     = State.form_selector
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shopping_address.errors, :status => :unprocessable_entity }
      end
    end
  end

  def select_address
    address = current_user.addresses.find(params[:id])
    update_order_address_id(address.id)
    respond_to do |format|
      format.html { redirect_to shopping_orders_url }
    end
  end
  # DELETE /shopping/addresses/1
  # DELETE /shopping/addresses/1.xml
  def destroy
    @shopping_address = Address.find(params[:id])
    @shopping_address.update_attributes(:active => false)

    respond_to do |format|
      format.html { redirect_to(shopping_addresses_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def form_info
    @shopping_addresses = current_user.shipping_addresses
    @states     = State.form_selector
  end
  
  def update_order_address_id(id)
    session_order.update_attributes(
                          :ship_address_id => id , 
                          :bill_address_id => (session_order.bill_address_id ? session_order.bill_address_id : id)
                                    )
  end
end
