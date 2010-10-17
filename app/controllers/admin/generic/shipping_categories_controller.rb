class Admin::Generic::ShippingCategoriesController < Admin::BaseController
  def index
    @shipping_categories = ShippingCategory.all
  end

  def new
    @shipping_category = ShippingCategory.new
  end

  def create
    @shipping_category = ShippingCategory.new(params[:shipping_category])
    if @shipping_category.save
      redirect_to :action => :index
    else
      flash[:error] = "The shipping category could not be saved"
      render :action => :new
    end
  end
  
  def edit
    @shipping_category = ShippingCategory.find(params[:id])
  end
  
  def update
    
    @shipping_category = ShippingCategory.find(params[:id])
    if @shipping_category.update_attributes(params[:shipping_category])
      redirect_to :action => :index
    else
      flash[:error] = "The shipping category could not be saved"
      render :action => :edit
    end
  end

end
