class Admin::Inventory::SuppliersController < Admin::BaseController
  helper_method :sort_column, :sort_direction
  respond_to :json, :html

  def index
    params[:page] ||= 1
    @suppliers = Supplier.admin_grid(params).order(sort_column + " " + sort_direction).
                                              paginate(:per_page => 25, :page => params[:page].to_i)
    respond_to do |format|
      format.html
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

  def sort_column
    Supplier.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
