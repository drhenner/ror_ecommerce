class Admin::Inventory::OverviewsController < Admin::BaseController

  def index

    params[:page] ||= 1
    params[:rows] ||= SETTINGS[:admin_grid_rows]

    @products = Product.where(['products.deleted_at IS NULL']).
                        order("#{params[:sidx]} #{params[:sord]}").
                        limit(params[:rows]).
                        includes({:variants => [{:variant_properties => :property}, :inventory]}).
                        paginate({:page => params[:page]})

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
