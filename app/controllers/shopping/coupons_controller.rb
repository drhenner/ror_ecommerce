class Shopping::CouponsController < Shopping::BaseController
  def show
    form_info
  end

  def create
    @coupon = Coupon.find_by_code(params[:coupon][:code])

    if @coupon && @coupon.eligible?(session_order) && update_order_coupon_id(@coupon.id)
      flash[:notice] = "Successfully added coupon code #{@coupon.code}."
      redirect_to next_form_url(session_order)
    else
      form_info
      flash[:notice] = "Sorry coupon code: #{params[:coupon][:code]} is not valid."
      render :action => 'show'
    end
  end

  private

  def form_info
    @coupon = Coupon.new
  end

  def update_order_coupon_id(id)
    session_order.update_attributes(
                          :coupon_id => id
                                    )
  end
end
