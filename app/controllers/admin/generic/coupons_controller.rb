class Admin::Generic::CouponsController < Admin::Generic::BaseController
  def index
    @coupons = Coupon.all
  end

  def show
    @coupon = Coupon.find(params[:id])
  end

  def new
    form_info
    @new_coupon = Coupon.new
    @coupon = Coupon.new
  end

  def create
      if params[:coupon][:c_type] == 'coupon_value'
        @new_coupon = CouponValue.new(params[:coupon])
      elsif params[:coupon][:c_type] == 'coupon_percent'
        @new_coupon = CouponPercent.new(params[:coupon])
      elsif params[:coupon][:c_type] == 'coupon_first_purchase_value'
        @new_coupon = CouponFirstPurchaseValue.new(params[:coupon])
      elsif params[:coupon][:c_type] == 'coupon_first_purchase_percent'
        @new_coupon = CouponFirstPurchasePercent.new(params[:coupon])
      else
        @new_coupon = Coupon.new(params[:coupon])
        @new_coupon.errors.add(:base, 'please select coupon type')
      end
    if @new_coupon.errors.size == 0 && @new_coupon.save
      flash[:notice] = "Successfully created coupon."
      redirect_to admin_generic_coupon_url(@new_coupon)
    else
      @coupon = Coupon.new(params[:coupon])
      form_info
      render :action => 'new'
    end
  end

  def edit
    form_info
    @new_coupon = Coupon.find(params[:id])
    @coupon = Coupon.find(params[:id])
  end

  def update
      @new_coupon = Coupon.find(params[:id])
    if @new_coupon.update_attributes(params[:coupon])
      flash[:notice] = "Successfully updated coupon."
      redirect_to admin_generic_coupon_url(@new_coupon)
    else
      @coupon = Coupon.find(params[:id])
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
