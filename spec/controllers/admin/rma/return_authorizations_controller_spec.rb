require 'spec_helper'

describe Admin::Rma::ReturnAuthorizationsController do

  def mock_return_authorization(stubs={})
    @mock_return_authorization ||= mock_model(ReturnAuthorization, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all return_authorizations as @return_authorizations" do
      ReturnAuthorization.stub(:all) { [mock_return_authorization] }
      get :index
      assigns(:return_authorizations).should eq([mock_return_authorization])
    end
  end

  describe "GET show" do
    it "assigns the requested return_authorization as @return_authorization" do
      ReturnAuthorization.stub(:find).with("37") { mock_return_authorization }
      get :show, :id => "37"
      assigns(:return_authorization).should be(mock_return_authorization)
    end
  end

  describe "GET new" do
    it "assigns a new return_authorization as @return_authorization" do
      ReturnAuthorization.stub(:new) { mock_return_authorization }
      get :new
      assigns(:return_authorization).should be(mock_return_authorization)
    end
  end

  describe "GET edit" do
    it "assigns the requested return_authorization as @return_authorization" do
      ReturnAuthorization.stub(:find).with("37") { mock_return_authorization }
      get :edit, :id => "37"
      assigns(:return_authorization).should be(mock_return_authorization)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created return_authorization as @return_authorization" do
        ReturnAuthorization.stub(:new).with({'these' => 'params'}) { mock_return_authorization(:save => true) }
        post :create, :return_authorization => {'these' => 'params'}
        assigns(:return_authorization).should be(mock_return_authorization)
      end

      it "redirects to the created return_authorization" do
        ReturnAuthorization.stub(:new) { mock_return_authorization(:save => true) }
        post :create, :return_authorization => {}
        response.should redirect_to(return_authorization_url(mock_return_authorization))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved return_authorization as @return_authorization" do
        ReturnAuthorization.stub(:new).with({'these' => 'params'}) { mock_return_authorization(:save => false) }
        post :create, :return_authorization => {'these' => 'params'}
        assigns(:return_authorization).should be(mock_return_authorization)
      end

      it "re-renders the 'new' template" do
        ReturnAuthorization.stub(:new) { mock_return_authorization(:save => false) }
        post :create, :return_authorization => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested return_authorization" do
        ReturnAuthorization.should_receive(:find).with("37") { mock_return_authorization }
        mock_return_authorization.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :return_authorization => {'these' => 'params'}
      end

      it "assigns the requested return_authorization as @return_authorization" do
        ReturnAuthorization.stub(:find) { mock_return_authorization(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:return_authorization).should be(mock_return_authorization)
      end

      it "redirects to the return_authorization" do
        ReturnAuthorization.stub(:find) { mock_return_authorization(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(return_authorization_url(mock_return_authorization))
      end
    end

    describe "with invalid params" do
      it "assigns the return_authorization as @return_authorization" do
        ReturnAuthorization.stub(:find) { mock_return_authorization(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:return_authorization).should be(mock_return_authorization)
      end

      it "re-renders the 'edit' template" do
        ReturnAuthorization.stub(:find) { mock_return_authorization(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested return_authorization" do
      ReturnAuthorization.should_receive(:find).with("37") { mock_return_authorization }
      mock_return_authorization.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the return_authorizations list" do
      ReturnAuthorization.stub(:find) { mock_return_authorization }
      delete :destroy, :id => "1"
      response.should redirect_to(return_authorizations_url)
    end
  end

end
