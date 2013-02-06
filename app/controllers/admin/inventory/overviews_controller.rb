class Admin::Inventory::OverviewsController < Admin::BaseController

  def index
    @products = Product.active.order("#{params[:sidx]} #{params[:sord]}").
                        includes({:variants => [{:variant_properties => :property}, :inventory]}).
                        paginate(:page => pagination_page, :per_page => pagination_rows)

  end

  def edit
    @product = Product.includes(:variants).find(params[:id])
  end

  def update
    @product = Product.find(params[:id])

    if @product.update_attributes(params[:product])
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

end
