require  'spec_helper'

describe Myaccount::StoreCreditsController do
  render_views

  it "show action should render show template" do
    user          = Factory(:user)
    @store_credit = Factory(:store_credit, :user => user)
    get :show, :id => @store_credit.id
    #response.should render_template(:show)
  end
end
