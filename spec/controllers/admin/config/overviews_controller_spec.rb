require 'spec_helper'

describe Admin::Config::OverviewsController, type: :controller do

  before(:each) do
    activate_authlogic
    @user = create_super_admin_user
    login_as(@user)
  end

  describe "GET index" do
    it "assigns all admin_config_overviews as @admin_config_overviews" do
      get :index
    end
  end

end
