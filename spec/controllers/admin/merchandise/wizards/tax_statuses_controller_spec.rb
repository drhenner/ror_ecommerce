require  'spec_helper'

describe Admin::Merchandise::Wizards::TaxStatusesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = Factory(:admin_user)
    login_as(@user)

    controller.session[:product_wizard] = {}
    controller.session[:product_wizard][:brand_id] = 7# @brand.id
    controller.session[:product_wizard][:product_type_id] = 7# @brand.id
    controller.session[:product_wizard][:property_ids]    = [1,2]
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "create action should render new template when model is invalid" do
    TaxStatus.any_instance.stubs(:valid?).returns(false)
    post :create, :tax_status =>{:name => 'test'}
    response.should render_template(:index)
  end

  it "create action should redirect when model is valid" do
    TaxStatus.any_instance.stubs(:valid?).returns(true)
    post :create, :tax_status =>{:name => 'test'}
    response.should redirect_to(admin_merchandise_wizards_shipping_categories_url)
  end

  it "update action should render edit template when model is invalid" do
    @tax_status = TaxStatus.first
    TaxStatus.stubs(:find_by_id).returns(nil)
    put :update, :id => @tax_status.id
    response.should render_template(:index)
  end

  it "update action should redirect when model is valid" do
    @tax_status = TaxStatus.first
    #TaxStatus.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @tax_status.id
    controller.session[:product_wizard][:tax_status_id].should == @tax_status.id
    response.should redirect_to(admin_merchandise_wizards_shipping_categories_url)
  end
end
