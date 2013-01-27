class Admin::Inventory::OverviewsController < Admin::BaseController

  def index
    @products = Product.where(['products.deleted_at IS NULL']).
                        order("#{params[:sidx]} #{params[:sord]}").
                        includes({:variants => [{:variant_properties => :property}, :inventory]}).
                        paginate(:page => pagination_page, :per_page => pagination_rows)

  end

  def edit
    @product = Product.includes(:variants).find(params[:id])
    form_info
  end

  def update
    @product = Product.find(params[:id])

    if @product.update_attributes(params[:product])
      redirect_to :action => :index
    else
      form_info
      render :action => :edit
    end
  end

  private

  def form_info

  end
end
