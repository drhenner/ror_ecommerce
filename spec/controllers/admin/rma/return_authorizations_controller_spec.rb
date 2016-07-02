require  'spec_helper'

describe Admin::Rma::ReturnAuthorizationsController do
  render_views

  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
    @order = FactoryGirl.create(:order, :state => 'complete')
  end

  it "index action should render index template" do
    @return_authorization = FactoryGirl.create(:return_authorization)
    get :index, params: { order_id: @order.id }
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @return_authorization = FactoryGirl.create(:return_authorization)
    get :show, params: { id: @return_authorization.id, order_id: @order.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new, params: { order_id: @order.id }
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    ReturnAuthorization.any_instance.stubs(:valid?).returns(false)
    post :create, params: { order_id: @order.id, return_authorization: { amount: '12.60', user_id: 1} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    ReturnAuthorization.any_instance.stubs(:valid?).returns(true)
    post :create, params: { order_id: @order.id, return_authorization: { amount: '12.60', user_id: 1} }
    expect(response).to redirect_to(admin_rma_order_return_authorization_url(@order, assigns[:return_authorization]))
  end

  it "edit action should render edit template" do
    @return_authorization = FactoryGirl.create(:return_authorization)
    get :edit, params: { id: @return_authorization.id, order_id: @order.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @return_authorization = FactoryGirl.create(:return_authorization)
    ReturnAuthorization.any_instance.stubs(:valid?).returns(false)
    put :update, params: { id: @return_authorization.id, order_id: @order.id, return_authorization: { amount: '12.60', user_id: 1} }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @return_authorization = FactoryGirl.create(:return_authorization)
    ReturnAuthorization.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: @return_authorization.id, order_id: @order.id, return_authorization: { amount: '12.60', user_id: 1} }
    expect(response).to redirect_to(admin_rma_order_return_authorization_url(@order, assigns[:return_authorization]))
  end

  it "update action should redirect when model is valid" do
    @return_authorization = FactoryGirl.create(:return_authorization)
    ReturnAuthorization.any_instance.stubs(:valid?).returns(true)
    put :complete, params: { id: @return_authorization.id, order_id: @order.id, return_authorization: { amount: '12.60', user_id: 1} }
    expect(ReturnAuthorization.find(@return_authorization.id).state).to eq 'complete'
  end

  it "destroy action should destroy model and redirect to index action" do
    @return_authorization = FactoryGirl.create(:return_authorization)
    delete :destroy, params: { id: @return_authorization.id, order_id: @order.id }
    expect(response).to redirect_to(admin_rma_order_return_authorization_url(@order, @return_authorization))
    expect(ReturnAuthorization.find(@return_authorization.id).state).to eq 'cancelled'
  end
end
