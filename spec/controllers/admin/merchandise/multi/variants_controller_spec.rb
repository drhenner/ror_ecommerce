require  'spec_helper'

describe Admin::Merchandise::Multi::VariantsController do
  render_views
  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "edit action should render edit template" do
    @product = create(:product)
    get :edit, product_id: @product.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, product_id: @product.id, product: product_attributes
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(true)
    Variant.any_instance.stubs(:valid?).returns(true)
    put :update, product_id: @product.id, product: product_attributes


    response.should redirect_to(admin_merchandise_product_url(@product))
  end

  def product_attributes
    {"variants_attributes" => {
      "new_variants" => {"sku"=>"0000-0000-000001", "price"=>"30.0", "cost"=>"10.0", "name"=>"", "inactivate"=>"0",
             "variant_properties_attributes" => {"0" => {"primary"=>"1", "property_id"=>"1", "description"=>"Red", "id"=>""},
                                               "1" => {"primary"=>"0", "property_id"=>"2", "description"=>"Small", "id"=>""},
                                               "2" => {"primary"=>"0", "property_id"=>"3", "description"=>""}} }
                            }}
  end

end
