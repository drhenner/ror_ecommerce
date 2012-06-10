require 'spec_helper'

describe Admin::Config::OverviewsController do

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
  end

  def mock_overview(stubs={})
    #@mock_overview ||= mock_model(Admin::Config::Overview, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all admin_config_overviews as @admin_config_overviews" do
      #Overview.stub(:all) { [mock_overview] }
      get :index
      #assigns(:overviews).should eq([mock_overview])
    end
  end

end
