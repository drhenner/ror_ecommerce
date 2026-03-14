class Shopping::CouponsController < Shopping::BaseController
  before_action :require_user

  def show
    form_info
  end

  def create
    coupon_code = params.dig(:coupon, :code)
    @coupon = Coupon.find_by_code(coupon_code) if coupon_code.present?

    if @coupon && @coupon.eligible?(session_order) && update_order_coupon_id(@coupon.id)
      flash[:notice] = "Successfully added coupon code #{@coupon.code}."
      redirect_to next_form_url(session_order)
    else
      form_info
      if coupon_code.present?
        flash.now[:alert] = "Sorry, coupon code '#{coupon_code}' is not valid."
      else
        flash.now[:alert] = "Please enter a coupon code."
      end
      render :action => 'show'
    end
  end

  private

  def form_info
    @coupon ||= Coupon.new
  end

  def update_order_coupon_id(id)
    session_order.update(
                          :coupon_id => id
                                    )
  end
end
