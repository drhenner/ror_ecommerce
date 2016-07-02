require  'spec_helper'

describe Admin::UserDatas::AddressesController do
  # fixtures :all
  render_views
  before(:each) do
    activate_authlogic
    @cur_user = FactoryGirl.create(:admin_user)
    login_as(@cur_user)
    @customer = FactoryGirl.create(:user)
  end

  it "index action should render index template" do
    address = FactoryGirl.create(:address, addressable_id: @customer.id, addressable_type: 'User')
    get :index, params: { user_id: @customer.id }
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    address = FactoryGirl.create(:address, addressable_id: @customer.id, addressable_type: 'User')
    get :show, params: { id: address.id, user_id: @customer.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new, params: { user_id: @customer.id }
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    address = FactoryGirl.build(:address, addressable_id: @customer.id, addressable_type: 'User')
    Address.any_instance.stubs(:valid?).returns(false)
    post :create, params: { user_id: @customer.id, address: address.attributes.reject {|k,v| ['id'].include?(k)} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    address = FactoryGirl.build(:address, addressable_id: @customer.id, addressable_type: 'User')
    Address.any_instance.stubs(:valid?).returns(true)
    post :create, params: { user_id: @customer.id, address: address.attributes.reject {|k,v| ['id'].include?(k)} }
    expect(response).to redirect_to(admin_user_datas_user_address_url(@customer, assigns[:address]))
  end

  it "edit action should render edit template" do
    address = FactoryGirl.create(:address, addressable_id: @customer.id, addressable_type: 'User')
    get :edit, params: { user_id: @customer.id, id: address.id}
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    address = FactoryGirl.create(:address, addressable_id: @customer.id, addressable_type: 'User')
    Address.any_instance.stubs(:valid?).returns(false)
    put :update, params: { user_id: @customer.id, id: address.id, address: address.attributes.reject {|k,v| ['id'].include?(k)}}
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    address = FactoryGirl.create(:address, addressable_id: @customer.id, addressable_type: 'User')
    Address.any_instance.stubs(:valid?).returns(true)
    put :update, params: { user_id: @customer.id, id: address.id, address: address.attributes.reject {|k,v| ['id'].include?(k)}}
    expect(response).to redirect_to(admin_user_datas_user_address_url(@customer, assigns[:address]))
  end

  it "destroy action should destroy model and redirect to index action" do
    address = FactoryGirl.create(:address, addressable_id: @customer.id, addressable_type: 'User')
    delete :destroy, params: { user_id: @customer.id, id: address.id }
    expect(Address.find(address.id).active).to eq false
  end
end
