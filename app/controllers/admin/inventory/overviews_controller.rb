class Admin::Inventory::OverviewsController < Admin::BaseController

  def index
    @products = Product.active.order("#{params[:sidx]} #{params[:sord]}").
                        includes({:variants => [{:variant_properties => :property}, :inventory]}).
                        paginate(:page => pagination_page, :per_page => pagination_rows)

  end

  def edit
    @product = Product.friendly.includes(:variants).find(params[:id])
  end

  def update
    @product = Product.friendly.find(params[:id])

    if @product.update_attributes(allowed_params)
      redirect_to action: :index
    else
      render action: :edit
    end
  end
  private

  def allowed_params
    params.require(:product).permit!
  end

end
