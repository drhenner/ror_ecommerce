require  'spec_helper'

describe Shopping::CouponsController do
  render_views

  it "show action should render show template" do
    get :show
    response.should render_template(:show)
  end

  it "create action should render show template when coupon is not eligible" do
    Coupon.any_instance.stubs(:eligible?).returns(false)
    post :create, :coupon => {:code => 'qwerty' }
    response.should render_template(:show)
  end

  it "create action should redirect when model is valid" do
    Factory(:coupon_value, :code => 'qwerty' )
    CouponValue.any_instance.stubs(:eligible?).returns(true)
    Shopping::CouponsController.any_instance.stubs(:update_order_coupon_id).returns(true)
    post :create, :coupon => {:code => 'qwerty' }
    response.should redirect_to(shopping_orders_url)
  end
end
