require  'spec_helper'

describe Admin::Merchandise::Products::DescriptionsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
  end

  it "edit action should render edit template" do
    @product = FactoryGirl.create(:product, :deleted_at => (Time.zone.now - 1.day), :description_markup => nil, :description => nil)
    get :edit, params: { id: @product.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @product = FactoryGirl.create(:product)
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => @product.id, :product => {:name => 'test', :description_markup => 'mark it up'} }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @product = FactoryGirl.create(:product, :deleted_at => (Time.zone.now - 1.day), :description_markup => nil, :description => nil)
    Product.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @product.id, :product => {:description_markup => '**Hi Everybody**'} }
    @product.reload
    expect(@product.description).not_to be_nil
    expect(response).to redirect_to(admin_merchandise_product_url(@product))
  end
end
