class Admin::Generic::CouponsController < Admin::Generic::BaseController
  def index
    @coupons = CouponValue.all
  end

  def show
    @coupon = CouponValue.find(params[:id])
  end

  def new
    form_info
    @coupon = CouponValue.new
  end

  def create
    @coupon = CouponValue.new(params[:coupon])
    if @coupon.save
      flash[:notice] = "Successfully created coupon."
      redirect_to admin_generic_coupon_url(@coupon)
    else
      form_info
      render :action => 'new'
    end
  end

  def edit
    form_info
    @coupon = CouponValue.find(params[:id])
  end

  def update
    @coupon = CouponValue.find(params[:id])
    if @coupon.update_attributes(params[:coupon])
      flash[:notice] = "Successfully updated coupon."
      redirect_to admin_generic_coupon_url(@coupon)
    else
      form_info
      render :action => 'edit'
    end
  end

  def destroy
    @coupon = CouponValue.find(params[:id])
    @coupon.destroy
    flash[:notice] = "Successfully destroyed coupon."
    redirect_to admin_generic_coupons_url
  end

  private

  def form_info

  end
end
