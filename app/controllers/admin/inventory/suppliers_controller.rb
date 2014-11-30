class Admin::Inventory::SuppliersController < Admin::BaseController
  helper_method :sort_column, :sort_direction

  def index
    @suppliers = Supplier.admin_grid(params).order(sort_column + " " + sort_direction).
                                              paginate(:page => pagination_page, :per_page => pagination_rows)
  end

  def new
    @supplier = Supplier.new
  end

  def create
    @supplier = Supplier.new(allowed_params)

    if @supplier.save
      redirect_to :action => :index
    else
      flash[:error] = "The supplier could not be saved"
      render :action => :new
    end
  end

  def edit
    @supplier = Supplier.find(params[:id])
  end

  def update
    @supplier = Supplier.find(params[:id])
    if @supplier.update_attributes(allowed_params)
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

  def show
    @supplier = Supplier.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @supplier }
    end
  end

private

  def allowed_params
    params.require(:supplier).permit(:name, :email)
  end

  def sort_column
    Supplier.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
