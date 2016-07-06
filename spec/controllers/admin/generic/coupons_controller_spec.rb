require  'spec_helper'

describe Admin::Generic::CouponsController do
  render_views

  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @coupon = create(:coupon)
    get :show, params: { id: @coupon.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    @coupon = create(:coupon)
    Coupon.any_instance.stubs(:valid?).returns(false)
    attribs =  @coupon.attributes
    attribs.delete('type')
    post :create, params: { :coupon => attribs, :c_type => 'CouponValue' }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @coupon = create(:coupon_value)
    CouponValue.any_instance.stubs(:valid?).returns(true)
    attribs =  @coupon.attributes
    attribs.delete('type')
    post :create, params: { :coupon => attribs, :c_type => 'CouponValue' }
    expect(response).to redirect_to(admin_generic_coupon_url(assigns[:coupon]))
  end

  it "edit action should render edit template" do
    @coupon = create(:coupon)
    get :edit, params: { :id => @coupon.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @coupon = create(:coupon)
    attribs =  @coupon.attributes
    attribs.delete('type')
    CouponValue.any_instance.stubs(:valid?).returns(false)
    put :update, params: { id: @coupon.id, coupon: attribs }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @coupon = create(:coupon)
    attribs =  @coupon.attributes
    attribs.delete('type')
    CouponValue.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: @coupon.id, coupon: attribs }
    expect(response).to redirect_to(admin_generic_coupon_url(assigns[:coupon]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @coupon = create(:coupon)
    delete :destroy, params: { id: @coupon.id }
    expect(response).to redirect_to(admin_generic_coupons_url)
    expect(Coupon.exists?(@coupon.id)).to eq false
  end
end
