require  'spec_helper'

describe Admin::CustomerService::CommentsController do
  # fixtures :all
  render_views
  before(:each) do
    activate_authlogic
    @customer = FactoryGirl.create(:user)
    @user = create_admin_user
    login_as(@user)
    @order = create(:order)
  end

  it "index action should render index template" do
    comment = FactoryGirl.create(:comment, :user_id => @customer.id, :commentable => @customer)
    get :index, params: { :user_id => @customer.id }
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    comment = FactoryGirl.create(:comment, :user_id => @customer.id, :commentable => @customer)
    get :show, params: { :id => comment.id, :user_id => @customer.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new, params: { user_id: @customer.id }
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    comment = FactoryGirl.build(:comment, :user_id => @customer.id, :commentable => @customer)
    Comment.any_instance.stubs(:valid?).returns(false)
    post :create, params: { user_id: @customer.id, comment: comment.attributes.reject {|k,v| ['id', 'commentable_type', 'commentable_id', 'created_by', 'user_id'].include?(k)} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    comment = FactoryGirl.build(:comment, :user_id => @customer.id, :commentable => @customer)
    Comment.any_instance.stubs(:valid?).returns(true)
    post :create, params: { user_id: @customer.id, comment: comment.attributes.reject {|k,v| ['id', 'commentable_type', 'commentable_id', 'created_by', 'user_id'].include?(k)} }
    expect(response).to redirect_to(admin_customer_service_user_url(@customer))
  end

end
