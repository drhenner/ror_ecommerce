class Admin::Inventory::PurchaseOrdersController < Admin::BaseController
  helper_method :sort_column, :sort_direction
  # GET /purchase_orders
  def index
    @purchase_orders = PurchaseOrder.admin_grid(params).order(sort_column + " " + sort_direction).
                                                        paginate(:page => pagination_page, :per_page => pagination_rows)

  end

  # GET /purchase_orders/1
  def show
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  # GET /purchase_orders/new
  def new
    @purchase_order = PurchaseOrder.new
    form_info
    if @select_suppliers.empty?
      flash[:notice] = 'You need to have a supplier before you can create a purchase order.'
      redirect_to new_admin_inventory_supplier_url
    end
  end

  # GET /purchase_orders/1/edit
  def edit
    @purchase_order = PurchaseOrder.find(params[:id])
    form_info
  end

  # POST /purchase_orders
  def create
    @purchase_order = PurchaseOrder.new(allowed_params)

    if @purchase_order.save
      redirect_to(:action => :index, :notice => 'Purchase order was successfully created.')
    else
      form_info
      render :action => "new"
    end
  end

  # PUT /purchase_orders/1
  def update
    @purchase_order = PurchaseOrder.find(params[:id])
    if @purchase_order.update_attributes(allowed_params)
      redirect_to(:action => :index, :notice => 'Purchase order was successfully updated.')
    else
      form_info
      render :action => "edit"
    end
  end

  # DELETE /purchase_orders/1
  def destroy
    @purchase_order = PurchaseOrder.find(params[:id])
    @purchase_order.destroy
    redirect_to(admin_inventory_purchase_orders_url)
  end
  private


  def allowed_params
    params.require(:purchase_order).permit!
  end

  def form_info
    @select_suppliers = Supplier.all.collect{|s| [s.name, s.id]}
    @select_variants  = Variant.includes(:product).collect {|v| [v.name_with_sku, v.id]}
  end

  def sort_column
    return 'suppliers.name' if params[:sort] == 'supplier_name'
    PurchaseOrder.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
