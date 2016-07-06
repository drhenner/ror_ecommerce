require  'spec_helper'

describe Admin::History::OrdersController do
  render_views

  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "show action should render show template" do
    @order = FactoryGirl.create(:order)
    get :show, params: { :id => @order.number }
    expect(response).to render_template(:show)
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end
end
