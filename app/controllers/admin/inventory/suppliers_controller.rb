class Admin::Inventory::SuppliersController < Admin::BaseController
  respond_to :json, :html

  def index
    @suppliers = Supplier.admin_grid(params)
    respond_to do |format|
      format.html
      format.json { render :json => @suppliers.to_jqgrid_json(
        [ :name, :email ],
        @suppliers.per_page,
        @suppliers.current_page,
        @suppliers.total_entries)

      }
    end
  end

  def new
    @supplier = Supplier.new
  end

  def create
    @supplier = Supplier.new(params[:supplier])

    if @supplier.save
      redirect_to :action => :index
    else
      form_info
      flash[:error] = "The supplier could not be saved"
      render :action => :new
    end
  end

  def edit
    @supplier = Supplier.find(params[:id])
  end

  def update
    @supplier = Supplier.find(params[:id])

    if @supplier.update_attributes(params[:supplier])
      redirect_to :action => :index
    else
      form_info
      render :action => :edit
    end
  end

  def show
    @supplier = Supplier.find(params[:id])
    respond_with(@supplier)
  end

private
  def form_info

  end
end
