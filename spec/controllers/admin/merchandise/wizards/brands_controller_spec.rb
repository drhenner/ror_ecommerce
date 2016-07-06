require  'spec_helper'

describe Admin::Merchandise::Wizards::BrandsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
    controller.session[:product_wizard] = {}
  end

  it "index action should render index template" do
    @brand = FactoryGirl.create(:brand)
    get :index
    expect(response).to render_template(:index)
  end

  it "create action should render new template when model is invalid" do
    Brand.any_instance.stubs(:valid?).returns(false)
    post :create, params: { brand: { name: 'prod brand'} }
    expect(response).to render_template(:index)
  end

  it "create action should redirect when model is valid" do
    Brand.any_instance.stubs(:valid?).returns(true)
    post :create, params: { brand: { name: 'prod brand'} }
    expect(controller.session[:product_wizard][:brand_id]).not_to be_nil
    expect(response).to redirect_to(admin_merchandise_wizards_product_types_url)
  end

  it "update action should render edit template when model is invalid" do
    @brand = FactoryGirl.create(:brand)
    Brand.stubs(:find_by_id).returns(nil)
    put :update, params: { id: @brand.id }
    expect(controller.session[:product_wizard][:brand_id]).to be_nil
    expect(response).to render_template(:index)
  end

  it "update action should redirect when model is valid" do
    @brand = FactoryGirl.create(:brand)
    #Brand.stubs(:find_by_id).returns(@brand)
    #Brand.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: @brand.id }
    expect(controller.session[:product_wizard][:brand_id]).not_to be_nil
    expect(response).to redirect_to(admin_merchandise_wizards_product_types_url)
  end
end
