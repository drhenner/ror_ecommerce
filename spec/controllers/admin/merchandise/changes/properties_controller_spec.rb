require  'spec_helper'

describe Admin::Merchandise::Changes::PropertiesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
    controller.session[:product_wizard] = {}
  end

  it "edit action should render edit template" do

    @product = FactoryGirl.create(:product)
    get :edit, params: { :product_id => @product.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    property = FactoryGirl.create(:property)
    @product = FactoryGirl.create(:product)
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :product_id => @product.id, :product => product_properties_attributes }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    property = FactoryGirl.create(:property)
    @product = FactoryGirl.create(:product)
    Product.any_instance.stubs(:valid?).returns(true)
    put :update, params: { product_id: @product.id, product: product_properties_attributes }
    expect(response).to redirect_to(admin_merchandise_product_url(@product.id))
  end

  def product_properties_attributes
    {"product_properties_attributes"=>{
                            "new_product_properties"=>{"_destroy"=>"false", "property_id"=>"1", "description"=>"", "position"=>""}}}
  end
end
