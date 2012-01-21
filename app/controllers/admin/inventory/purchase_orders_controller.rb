class Admin::Inventory::PurchaseOrdersController < Admin::BaseController
  helper_method :sort_column, :sort_direction
  # GET /purchase_orders
  def index
    params[:page] ||= 1
    @purchase_orders = PurchaseOrder.admin_grid(params).order(sort_column + " " + sort_direction).
                                                        paginate(:per_page => 25, :page => params[:page].to_i)

    respond_to do |format|
      format.html
    end
  end

  # GET /purchase_orders/1
  def show
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  # GET /purchase_orders/new
  # GET /purchase_orders/new.xml
  def new
    @purchase_order = PurchaseOrder.new
    #@purchase_order.purchase_order_variants << PurchaseOrderVariant.new
    form_info
    if @select_suppliers.empty?
      flash[:notice] = 'You need to have a supplier before you can create a purchase order.'
      redirect_to new_admin_inventory_supplier_url
    else
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  end

  # GET /purchase_orders/1/edit
  def edit
    @purchase_order = PurchaseOrder.find(params[:id])
    form_info
  end

  # POST /purchase_orders
  def create
    #args = params[:purchase_order].reject{|key,val| key == :new_purchase_order_variants}
    @purchase_order = PurchaseOrder.new(params[:purchase_order])

    respond_to do |format|
      if @purchase_order.save
        format.html { redirect_to(:action => :index, :notice => 'Purchase order was successfully created.') }
      else
        form_info
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /purchase_orders/1
  def update
    @purchase_order = PurchaseOrder.find(params[:id])
    respond_to do |format|
      if @purchase_order.update_attributes(params[:purchase_order])
        format.html { redirect_to(:action => :index, :notice => 'Purchase order was successfully updated.') }
      else
        form_info
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /purchase_orders/1
  def destroy
    @purchase_order = PurchaseOrder.find(params[:id])
    @purchase_order.destroy
    redirect_to(admin_inventory_purchase_orders_url)
  end
  private

  def form_info
    @select_suppliers = Supplier.all.collect{|s| [s.name, s.id]}
    @select_variants  = Variant.includes(:product).all.collect {|v| [v.name_with_sku, v.id]}
  end

  def sort_column
    return 'suppliers.name' if params[:sort] == 'supplier_name'
    PurchaseOrder.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
