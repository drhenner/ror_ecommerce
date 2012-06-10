require  'spec_helper'

describe Shopping::CouponsController do
  render_views

  before(:each) do
    activate_authlogic

    @cur_user = create(:user)
    login_as(@cur_user)

    #stylist_cart
    @variant  = create(:variant)

    create_cart(@cur_user, @cur_user, [@variant])

    @address      = create(:address)
    @order        = create(:order, :ship_address_id => @address.id)
    @order_item   = create(:order_item, :order => @order, :variant => @variant)
    @order.stubs(:order_items).returns([@order_item])
    @controller.stubs(:find_or_create_order).returns(@order)
  end

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
    create(:coupon_value, :code => 'qwerty' )
    CouponValue.any_instance.stubs(:eligible?).returns(true)
    Shopping::CouponsController.any_instance.stubs(:update_order_coupon_id).returns(true)
    post :create, :coupon => {:code => 'qwerty' }
    response.should redirect_to(shopping_orders_url)
  end
end
