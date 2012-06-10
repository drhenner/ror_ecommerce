require  'spec_helper'

describe Myaccount::AddressesController do
  render_views


  before(:each) do
    activate_authlogic

    @user = create(:user)
    login_as(@user)
  end


  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    @address = create(:address, :addressable => @user)
    get :show, :id => @address.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Address.any_instance.stubs(:valid?).returns(false)
    address = build(:address)
    post :create, :address => address.attributes
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Address.any_instance.stubs(:valid?).returns(true)
    address = build(:address)
    post :create, :address => address.attributes
    response.should redirect_to(myaccount_address_url(assigns[:address]))
  end

  it "edit action should render edit template" do
    @address = create(:address, :addressable => @user)
    get :edit, :id => @address.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @address = create(:address, :addressable => @user)
    Address.any_instance.stubs(:valid?).returns(false)
    address = build(:address, :default => true)
    put :update, :id => @address.id, :address => address.attributes
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @address = create(:address, :addressable => @user)
    Address.any_instance.stubs(:valid?).returns(true)
    address = build(:address, :default => true)
    put :update, :id => @address.id, :address => address.attributes
    response.should redirect_to(myaccount_address_url(assigns[:address]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @address = create(:address, :addressable => @user)
    delete :destroy, :id => @address.id
    response.should redirect_to(myaccount_addresses_url)
    Address.exists?(@address.id).should be_true
    a = Address.find(@address.id)
    a.active.should be_false
  end
end
