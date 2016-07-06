require  'spec_helper'

describe Shopping::CouponsController do
  render_views

  before(:each) do
    activate_authlogic

    @cur_user = FactoryGirl.create(:user)
    login_as(@cur_user)

    #stylist_cart
    @variant  = FactoryGirl.create(:variant)

    create_cart(@cur_user, @cur_user, [@variant])

    @address      = FactoryGirl.create(:address)
    @order        = FactoryGirl.create(:order, :ship_address_id => @address.id)
    @order_item   = FactoryGirl.create(:order_item, :order => @order, :variant => @variant)
    @order.stubs(:order_items).returns([@order_item])
    @controller.stubs(:find_or_create_order).returns(@order)
  end

  it "show action should render show template" do
    get :show
    expect(response).to render_template(:show)
  end

  it "create action should render show template when coupon is not eligible" do
    Coupon.any_instance.stubs(:eligible?).returns(false)
    post :create, params: { coupon: { code: 'qwerty' } }
    expect(response).to render_template(:show)
  end

  it "create action should redirect when model is valid" do
    FactoryGirl.create(:coupon_value, :code => 'qwerty' )
    CouponValue.any_instance.stubs(:eligible?).returns(true)
    Shopping::CouponsController.any_instance.stubs(:update_order_coupon_id).returns(true)
    @controller.expects(:next_form_url).returns(shopping_orders_url)
    post :create, params: {coupon: { code: 'qwerty' }}
    expect(response).to redirect_to(shopping_orders_url)
  end
end
