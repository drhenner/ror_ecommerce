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

    @product = create(:product)
    get :edit, :product_id => @product.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    property = create(:property)
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, :product_id => @product.id, :product => product_properties_attributes
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    property = create(:property)
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(true)
    put :update, product_id: @product.id, product: product_properties_attributes
    response.should redirect_to(admin_merchandise_product_url(@product.id))
  end

  def product_properties_attributes
    {"product_properties_attributes"=>{
                            "new_product_properties"=>{"_destroy"=>"false", "property_id"=>"1", "description"=>"", "position"=>""}}}
  end
end
