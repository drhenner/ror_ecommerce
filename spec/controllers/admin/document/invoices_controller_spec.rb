require File.dirname(__FILE__) + '/../../../spec_helper'

describe Admin::Document::InvoicesController do
  render_views

  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    invoice = FactoryGirl.create(:invoice)
    get :show, params: { id: invoice.id }
    expect(response).to render_template(:show)
  end

end
