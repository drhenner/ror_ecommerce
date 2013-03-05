require  'spec_helper'

describe Admin::Reports::OverviewsController do
  # fixtures :all
  render_views
  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "show action should render show template" do
    get :show
    expect(response).to render_template(:show)
  end
end
