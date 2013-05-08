# Use this model to create 20% off sales for any given product

class Admin::Generic::SalesController < Admin::Generic::BaseController
  helper_method :sort_column, :sort_direction, :products
  def index
    @sales = Sale.order(sort_column + " " + sort_direction).
                                              paginate(:page => pagination_page, :per_page => pagination_rows)
  end

  def show
    @sale = Sale.find(params[:id])
  end

  def new
    @sale = Sale.new
  end

  def create
    @sale = Sale.new(allowed_params)
    if @sale.save
      redirect_to [:admin, :generic, @sale], :notice => "Successfully created sale."
    else
      render :new
    end
  end

  def edit
    @sale = Sale.find(params[:id])
  end

  def update
    @sale = Sale.find(params[:id])
    if @sale.update_attributes(allowed_params)
      redirect_to [:admin, :generic, @sale], :notice  => "Successfully updated sale."
    else
      render :edit
    end
  end

  def destroy
    @sale = Sale.find(params[:id])
    @sale.destroy
    redirect_to admin_generic_sales_url, :notice => "Successfully destroyed sale."
  end

  private

    def allowed_params
      params.require(:sale).permit(:product_id, :percent_off, :starts_at, :ends_at)
    end

    def products
      @products ||= Product.select([:id, :name]).map{|p| [p.name, p.id]}
    end

    def sort_column
      Sale.column_names.include?(params[:sort]) ? params[:sort] : "product_id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
