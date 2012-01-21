class Admin::Merchandise::ProductTypesController < Admin::BaseController
  helper_method :sort_column, :sort_direction
  respond_to :html, :json
  def index
    params[:page] ||= 1
    @product_types = ProductType.admin_grid(params).order(sort_column + " " + sort_direction).
                                              paginate(:per_page => 25, :page => params[:page].to_i)
    respond_to do |format|
      format.html
    end
  end

  def show
    @product_type = ProductType.find(params[:id])
    respond_with(@product_type)
  end

  def new
    @product_type = ProductType.new
    form_info
  end

  def create
    @product_type = ProductType.new(params[:product_type])

    if @product_type.save
      redirect_to :action => :index
    else
      form_info
      flash[:error] = "The product_type could not be saved"
      render :action => :new
    end
  end

  def edit
    @product_type = ProductType.find(params[:id])
    form_info
  end

  def update
    @product_type = ProductType.find(params[:id])

    if @product_type.update_attributes(params[:product_type])
      redirect_to :action => :index
    else
      form_info
      render :action => :edit
    end
  end

  def destroy
    @product_type = ProductType.find(params[:id])
    @product_type.active = false
    @product_type.save

    redirect_to :action => :index
  end

  private

  def form_info
    @product_types = ProductType.all
  end

  def sort_column
    ProductType.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
