require  'spec_helper'

describe Admin::Generic::CouponsController do
  render_views

  before(:each) do
    activate_authlogic
    @user = Factory(:admin_user)
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    @coupon = Factory(:coupon)
    get :show, :id => @coupon.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    @coupon = Factory(:coupon)
    CouponValue.any_instance.stubs(:valid?).returns(false)
    post :create, :coupon => @coupon.attributes.merge(:type => 'coupon_value')
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @coupon = Factory(:coupon_value)
    CouponValue.any_instance.stubs(:valid?).returns(true)
    post :create, :coupon => @coupon.attributes.merge(:type => 'coupon_value')
    response.should redirect_to(admin_generic_coupon_url(assigns[:coupon]))
  end

  it "edit action should render edit template" do
    @coupon = Factory(:coupon)
    get :edit, :id => @coupon.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @coupon = Factory(:coupon)
    CouponValue.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @coupon.id, :coupon => @coupon.attributes
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @coupon = Factory(:coupon)
    CouponValue.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @coupon.id, :coupon => @coupon.attributes
    response.should redirect_to(admin_generic_coupon_url(assigns[:coupon]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @coupon = Factory(:coupon)
    delete :destroy, :id => @coupon.id
    response.should redirect_to(admin_generic_coupons_url)
    Coupon.exists?(@coupon.id).should be_false
  end
end
