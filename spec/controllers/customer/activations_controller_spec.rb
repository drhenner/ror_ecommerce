require  'spec_helper'

describe Customer::ActivationsController do
  render_views

  it "show action should render show template" do
    @user = FactoryGirl.create(:user, state: 'inactive')
    get :show, params: {id: @user.id, a: @user.perishable_token}
    expect(assigns[:user].id).to eq @user.id
    expect(response).to redirect_to(root_url)
  end

  it "show action should render show template" do
    @user = FactoryGirl.create(:user, state: 'inactive')
    get :show, params: {id: @user.id, a: 'bad0perishabletoken'}
    expect(assigns[:user]).to eq nil
    expect(response).to redirect_to(root_url)
  end

end
