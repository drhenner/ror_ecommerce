require  'spec_helper'

describe Customer::ActivationsController do
  render_views

  it "show action should render show template" do
    @user = create(:user, :state => 'inactive')
    get :show, :id => @user.id, :a => @user.perishable_token
    assigns[:user].id.should == @user.id
    response.should redirect_to(root_url)
  end

  it "show action should render show template" do
    @user = create(:user, :state => 'inactive')
    get :show, :id => @user.id, :a => 'bad0perishabletoken'
    assigns[:user].should == nil
    response.should redirect_to(root_url)
  end

end
