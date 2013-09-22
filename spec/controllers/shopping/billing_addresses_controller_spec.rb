require  'spec_helper'

describe Shopping::BillingAddressesController do
  render_views

  before(:each) do
    activate_authlogic
    @cur_user = create(:user)
    login_as(@cur_user)

    @variant  = create(:variant)
    create_cart(@cur_user, @cur_user, [@variant])
    @billing_address = create(:address, :addressable_id => @cur_user.id, :addressable_type => 'User')
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "create action should render new template when model is invalid" do
    Address.any_instance.stubs(:valid?).returns(false)
    post :create, :address => @billing_address.attributes
    response.should render_template(:index)
  end

  it "create action should redirect when model is valid" do
    Address.any_instance.stubs(:valid?).returns(true)
    controller.stubs(:next_form_url).returns(shopping_shipping_methods_url)
    post :create, :address => @billing_address.attributes
    response.should redirect_to(shopping_shipping_methods_url)
  end

  it "edit action should render edit template" do
    get :edit, :id => @billing_address.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    Address.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @billing_address.id, :address => @billing_address.attributes
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    Address.any_instance.stubs(:valid?).returns(true)
    controller.stubs(:next_form_url).returns(shopping_shipping_methods_url)
    put :update, :id => @billing_address.id, :address => @billing_address.attributes
    response.should redirect_to(shopping_shipping_methods_url)
  end

  it "update action should redirect when model is valid" do
    Address.any_instance.stubs(:valid?).returns(true)
    controller.stubs(:next_form_url).returns(shopping_shipping_methods_url)
    put :select_address, :id => @billing_address.id
    response.should redirect_to(shopping_shipping_methods_url)
  end
end
