class Admin::Generic::CouponsController < Admin::Generic::BaseController
  def index
    @coupons = Coupon.all
  end

  def show
    @coupon = Coupon.find(params[:id])
  end

  def new
    form_info
    @coupon = Coupon.new
  end

  def create
    @coupon = Coupon.new(params[:coupon])
    @coupon.type = params[:c_type]
    @coupon.errors.add(:base, 'please select coupon type') if params[:c_type].blank?
    if @coupon.errors.size == 0 && @coupon.save
      flash[:notice] = "Successfully created coupon."
      redirect_to admin_generic_coupon_url(@coupon)
    else
      form_info
      render :action => 'new'
    end
  end

  def edit
    form_info
    @coupon = Coupon.find(params[:id])
  end

  def update
      @coupon = Coupon.find(params[:id])
    if @coupon.update_attributes(params[:coupon])
      flash[:notice] = "Successfully updated coupon."
      redirect_to admin_generic_coupon_url(@coupon)
    else
      form_info
      render :action => 'edit'
    end
  end

  def destroy
    @coupon = Coupon.find(params[:id])
    @coupon.destroy
    flash[:notice] = "Successfully destroyed coupon."
    redirect_to admin_generic_coupons_url
  end

  private

  def form_info
    @coupon_types = Coupon::COUPON_TYPES
  end
end
