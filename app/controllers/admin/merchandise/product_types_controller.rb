class Admin::Merchandise::ProductTypesController < Admin::BaseController
  respond_to :html, :json
  def index
    @product_types = ProductType.admin_grid(params)
    respond_to do |format|
      format.html
      format.json { render :json => @product_types.to_jqgrid_json(
        [ :name ],
        @product_types.per_page, #params[:page],
        @product_types.current_page, #params[:rows],
        @product_types.total_entries)

      }
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

end
