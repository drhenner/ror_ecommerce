require  'spec_helper'

describe Admin::Rma::ReturnAuthorizationsController do
  render_views

  before(:each) do
    activate_authlogic
    @user = create(:admin_user)
    login_as(@user)
    @order = create(:order, :state => 'complete')
  end

  it "index action should render index template" do
    @return_authorization = create(:return_authorization)
    get :index, :order_id => @order.id
    response.should render_template(:index)
  end

  it "show action should render show template" do
    @return_authorization = create(:return_authorization)
    get :show, :id => @return_authorization.id, :order_id => @order.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new, :order_id => @order.id
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    ReturnAuthorization.any_instance.stubs(:valid?).returns(false)
    post :create, :order_id => @order.id
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    ReturnAuthorization.any_instance.stubs(:valid?).returns(true)
    post :create, :order_id => @order.id, :return_authorization => {:amount => '12.60', :user_id => 1}
    response.should redirect_to(admin_rma_order_return_authorization_url(@order, assigns[:return_authorization]))
  end

  it "edit action should render edit template" do
    @return_authorization = create(:return_authorization)
    get :edit, :id => @return_authorization.id, :order_id => @order.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @return_authorization = create(:return_authorization)
    ReturnAuthorization.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @return_authorization.id, :order_id => @order.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @return_authorization = create(:return_authorization)
    ReturnAuthorization.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @return_authorization.id, :order_id => @order.id
    response.should redirect_to(admin_rma_order_return_authorization_url(@order, assigns[:return_authorization]))
  end

  it "update action should redirect when model is valid" do
    @return_authorization = create(:return_authorization)
    ReturnAuthorization.any_instance.stubs(:valid?).returns(true)
    put :complete, :id => @return_authorization.id, :order_id => @order.id
    ReturnAuthorization.find(@return_authorization.id).state.should == 'complete'
  end

  it "destroy action should destroy model and redirect to index action" do
    @return_authorization = create(:return_authorization)
    delete :destroy, :id => @return_authorization.id, :order_id => @order.id
    response.should redirect_to(admin_rma_order_return_authorization_url(@order, @return_authorization))
    ReturnAuthorization.find(@return_authorization.id).state.should == 'cancelled'
  end
end
