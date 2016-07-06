require  'spec_helper'

describe Admin::Merchandise::ProductsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)

    controller.stubs(:current_ability).returns(Ability.new(@user))
  end

  it "edit action should render edit template" do
    @product = FactoryGirl.create(:product)
    get :edit, params: { id: @product.permalink }
    expect(response).to render_template(:edit)
  end

  #it "update action should render edit template when model is invalid" do
  #  @product = create(:product)
  #  Product.any_instance.stubs(:valid?).returns(false)
  #  put :update, id: @product.permalink, :product => product_attributes
  #  expect(response).to render_template(:edit)
  #end
  #
  #it "update action should redirect when model is valid" do
  #  @product = create(:product)
  #  Product.any_instance.stubs(:valid?).returns(true)
  #  put :update, id: @product.id, :product => product_attributes
  #  expect(response).to redirect_to(admin_merchandise_product_url(assigns[:product]))
  #end

  def product_attributes
    {:name => 'cute pants', :set_keywords => 'test,one,two,three', :product_type_id => 1, :prototype_id => nil, :shipping_category_id => 1, :permalink => 'linkToMe', :available_at => Time.zone.now, :deleted_at => nil, :meta_keywords => 'cute,pants,bacon', :meta_description => 'good pants', :featured => true, :brand_id => 1}
  end
end
