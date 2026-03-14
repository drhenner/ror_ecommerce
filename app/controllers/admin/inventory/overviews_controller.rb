class Admin::Inventory::OverviewsController < Admin::BaseController

  def index
    @pagy, @products = pagy(Product.active.order(sort_column + " " + sort_direction).
                        includes({:variants => [{:variant_properties => :property}, :inventory]}), limit: pagination_rows)

  end

  def edit
    @product = Product.friendly.includes(:variants).find(params[:id])
  end

  def update
    @product = Product.friendly.find(params[:id])

    if @product.update(allowed_params)
      redirect_to action: :index
    else
      render action: :edit
    end
  end

  private

  def allowed_params
    params.require(:product).permit!
  end

  def sort_column
    Product.column_names.include?(params[:sidx]) ? params[:sidx] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:sord]) ? params[:sord] : "asc"
  end
end
