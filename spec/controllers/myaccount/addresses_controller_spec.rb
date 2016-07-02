require  'spec_helper'

describe Myaccount::AddressesController do
  render_views

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    activate_authlogic

    login_as(user)
  end


  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @address = FactoryGirl.create(:address, addressable: user)
    get :show, params: {id: @address.id}
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Address.any_instance.stubs(:valid?).returns(false)
    address = FactoryGirl.build(:address)
    post :create, params: {address: address.attributes}
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Address.any_instance.stubs(:valid?).returns(true)
    address = FactoryGirl.build(:address)
    post :create, params: {address: address.attributes}
    expect(response).to redirect_to(myaccount_address_url(assigns[:address]))
  end

  it "edit action should render edit template" do
    @address = FactoryGirl.create(:address, addressable: user)
    get :edit, params: {id: @address.id}
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @address = FactoryGirl.create(:address, addressable: user)
    Address.any_instance.stubs(:valid?).returns(false)
    address = build(:address, default: true)
    put :update, params: {id: @address.id, address: address.attributes}
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @address = FactoryGirl.create(:address, addressable: user)
    Address.any_instance.stubs(:valid?).returns(true)
    address = build(:address, default: true)
    put :update, params: {id: @address.id, address: address.attributes}
    expect(response).to redirect_to(myaccount_address_url(assigns[:address]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @address = FactoryGirl.create(:address, addressable: user)
    delete :destroy, params: {id: @address.id}
    expect(response).to redirect_to(myaccount_addresses_url)
    expect(Address.exists?(@address.id)).to be true
    a = Address.find(@address.id)
    expect(a.active).to eq false
  end
end
