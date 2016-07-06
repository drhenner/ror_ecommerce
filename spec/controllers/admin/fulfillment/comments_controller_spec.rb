require  'spec_helper'

describe Admin::Fulfillment::CommentsController do
  render_views

  before(:each) do
    @order = FactoryGirl.create(:order)
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    get :index, params: { order_id: @order.number }
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @comment = FactoryGirl.create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    get :show, params: { id: @comment.id, order_id: @order.number }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new, params: { order_id: @order.number }
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    @comment = FactoryGirl.create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :order_id => @order.number, :comment => @comment.attributes }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @comment = FactoryGirl.create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(true)
    post :create, params: { order_id: @order.number, comment: @comment.attributes }
    #expect(response).to redirect_to(admin_fulfillment_order_comment_url(@order, assigns[:comment]))
    expect(response).to render_template(:show)
  end

  it "create action should redirect when model is valid" do
    @comment = FactoryGirl.create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :order_id => @order.number, :comment => @comment.attributes, :format => 'json' }
    #expect(response).to redirect_to(admin_fulfillment_order_comment_url(@order, assigns[:comment]))
    expect(response.body).to eq assigns[:comment].to_json()
  end

  it "edit action should render edit template" do
    @comment = FactoryGirl.create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    get :edit, params: { :id => @comment.id, :order_id => @order.number }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @comment = FactoryGirl.create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => @comment.id, :order_id => @order.number, :comment => @comment.attributes }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @comment = FactoryGirl.create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @comment.id, :order_id => @order.number, :comment => @comment.attributes }
    expect(response).to redirect_to(admin_fulfillment_order_comment_url(@order, assigns[:comment]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @comment = FactoryGirl.create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    delete :destroy, params: { :id => @comment.id, :order_id => @order.number }
    expect(response).to redirect_to(admin_fulfillment_order_comments_url(@order))
    expect(Comment.exists?(@comment.id)).to eq false
  end
end
