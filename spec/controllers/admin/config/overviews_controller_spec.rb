require 'spec_helper'

describe Admin::Config::OverviewsController do

  def mock_overview(stubs={})
    @mock_overview ||= mock_model(Admin::Config::Overview, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all admin_config_overviews as @admin_config_overviews" do
      Admin::Config::Overview.stub(:all) { [mock_overview] }
      get :index
      assigns(:admin_config_overviews).should eq([mock_overview])
    end
  end

  describe "GET show" do
    it "assigns the requested overview as @overview" do
      Admin::Config::Overview.stub(:find).with("37") { mock_overview }
      get :show, :id => "37"
      assigns(:overview).should be(mock_overview)
    end
  end

  describe "GET new" do
    it "assigns a new overview as @overview" do
      Admin::Config::Overview.stub(:new) { mock_overview }
      get :new
      assigns(:overview).should be(mock_overview)
    end
  end

  describe "GET edit" do
    it "assigns the requested overview as @overview" do
      Admin::Config::Overview.stub(:find).with("37") { mock_overview }
      get :edit, :id => "37"
      assigns(:overview).should be(mock_overview)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created overview as @overview" do
        Admin::Config::Overview.stub(:new).with({'these' => 'params'}) { mock_overview(:save => true) }
        post :create, :overview => {'these' => 'params'}
        assigns(:overview).should be(mock_overview)
      end

      it "redirects to the created overview" do
        Admin::Config::Overview.stub(:new) { mock_overview(:save => true) }
        post :create, :overview => {}
        response.should redirect_to(admin_config_overview_url(mock_overview))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved overview as @overview" do
        Admin::Config::Overview.stub(:new).with({'these' => 'params'}) { mock_overview(:save => false) }
        post :create, :overview => {'these' => 'params'}
        assigns(:overview).should be(mock_overview)
      end

      it "re-renders the 'new' template" do
        Admin::Config::Overview.stub(:new) { mock_overview(:save => false) }
        post :create, :overview => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested overview" do
        Admin::Config::Overview.should_receive(:find).with("37") { mock_overview }
        mock_admin_config_overview.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :overview => {'these' => 'params'}
      end

      it "assigns the requested overview as @overview" do
        Admin::Config::Overview.stub(:find) { mock_overview(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:overview).should be(mock_overview)
      end

      it "redirects to the overview" do
        Admin::Config::Overview.stub(:find) { mock_overview(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(admin_config_overview_url(mock_overview))
      end
    end

    describe "with invalid params" do
      it "assigns the overview as @overview" do
        Admin::Config::Overview.stub(:find) { mock_overview(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:overview).should be(mock_overview)
      end

      it "re-renders the 'edit' template" do
        Admin::Config::Overview.stub(:find) { mock_overview(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested overview" do
      Admin::Config::Overview.should_receive(:find).with("37") { mock_overview }
      mock_admin_config_overview.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the admin_config_overviews list" do
      Admin::Config::Overview.stub(:find) { mock_overview }
      delete :destroy, :id => "1"
      response.should redirect_to(admin_config_overviews_url)
    end
  end

end
