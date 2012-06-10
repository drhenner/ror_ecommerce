require  'spec_helper'

describe Admin::History::OrdersController do
  render_views

  before(:each) do
    activate_authlogic
    @user = create(:admin_user)
    login_as(@user)
  end

  it "show action should render show template" do
    @order = create(:order)
    get :show, :id => @order.number
    response.should render_template(:show)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
end
