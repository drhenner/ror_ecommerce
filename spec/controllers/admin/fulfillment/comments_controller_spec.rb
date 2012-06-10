require  'spec_helper'

describe Admin::Fulfillment::CommentsController do
  render_views

  before(:each) do
    @order = create(:order)
    activate_authlogic
    @user = create(:admin_user)
    login_as(@user)
  end

  it "index action should render index template" do
    get :index, :order_id => @order.number
    response.should render_template(:index)
  end

  it "show action should render show template" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    get :show, :id => @comment.id, :order_id => @order.number
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new, :order_id => @order.number
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(false)
    post :create, :order_id => @order.number, :comment => @comment.attributes
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(true)
    post :create, :order_id => @order.number, :comment => @comment.attributes
    #response.should redirect_to(admin_fulfillment_order_comment_url(@order, assigns[:comment]))
    response.should render_template(:show)
  end


  it "create action should redirect when model is valid" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(true)
    post :create, :order_id => @order.number, :comment => @comment.attributes, :format => 'json'
    #response.should redirect_to(admin_fulfillment_order_comment_url(@order, assigns[:comment]))
    response.body.should == assigns[:comment].to_json()
  end

  it "edit action should render edit template" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    get :edit, :id => @comment.id, :order_id => @order.number
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @comment.id, :order_id => @order.number, :comment => @comment.attributes
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @comment.id, :order_id => @order.number, :comment => @comment.attributes
    response.should redirect_to(admin_fulfillment_order_comment_url(@order, assigns[:comment]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    delete :destroy, :id => @comment.id, :order_id => @order.number
    response.should redirect_to(admin_fulfillment_order_comments_url(@order))
    Comment.exists?(@comment.id).should be_false
  end
end
