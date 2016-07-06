require  'spec_helper'

describe Admin::Inventory::AdjustmentsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
    @product = FactoryGirl.create(:product)
  end

  it "show action should render show template" do
    @product = FactoryGirl.create(:product)
    get :show, params: { :id => @product.id }
    expect(response).to render_template(:show)
  end

  it "index action should render index template" do
    @product = FactoryGirl.create(:product)
    get :index
    expect(response).to render_template(:index)
  end

  it "edit action should render edit template" do
    @variant = FactoryGirl.create(:variant)
    get :edit, params: { :id => @variant.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @variant = FactoryGirl.create(:variant)
    Variant.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => @variant.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit when no refund is passed" do
    @product = FactoryGirl.create(:product)
    @variant = FactoryGirl.create(:variant, :product => @product)
    Variant.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @variant.id, :variant => {:qty_to_add => '-3'} }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @product = FactoryGirl.create(:product)
    @variant = FactoryGirl.create(:variant, :product => @product)
    Variant.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @variant.id, :variant => {:qty_to_add => '-3'}, :refund => '12.09' }
    expect(response).to redirect_to(admin_inventory_adjustment_url(@product))
  end

  it "update action should redirect when model is valid" do
    @product = FactoryGirl.create(:product)
    @variant = FactoryGirl.create(:variant, :product => @product)
    Variant.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @variant.id, :variant => {:qty_to_add => '-3'}, :refund => '00.0' }
    expect(response).to redirect_to(admin_inventory_adjustment_url(@product))
  end
end
