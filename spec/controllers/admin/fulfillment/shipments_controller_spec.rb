require 'spec_helper'

describe Admin::Fulfillment::ShipmentsController do

  def mock_shipment(stubs={})
    @mock_shipment ||= mock_model(Admin::Fulfillment::Shipment, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all admin_fulfillment_shipments as @admin_fulfillment_shipments" do
      Admin::Fulfillment::Shipment.stub(:all) { [mock_shipment] }
      get :index
      assigns(:admin_fulfillment_shipments).should eq([mock_shipment])
    end
  end

  describe "GET show" do
    it "assigns the requested shipment as @shipment" do
      Admin::Fulfillment::Shipment.stub(:find).with("37") { mock_shipment }
      get :show, :id => "37"
      assigns(:shipment).should be(mock_shipment)
    end
  end

  describe "GET new" do
    it "assigns a new shipment as @shipment" do
      Admin::Fulfillment::Shipment.stub(:new) { mock_shipment }
      get :new
      assigns(:shipment).should be(mock_shipment)
    end
  end

  describe "GET edit" do
    it "assigns the requested shipment as @shipment" do
      Admin::Fulfillment::Shipment.stub(:find).with("37") { mock_shipment }
      get :edit, :id => "37"
      assigns(:shipment).should be(mock_shipment)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created shipment as @shipment" do
        Admin::Fulfillment::Shipment.stub(:new).with({'these' => 'params'}) { mock_shipment(:save => true) }
        post :create, :shipment => {'these' => 'params'}
        assigns(:shipment).should be(mock_shipment)
      end

      it "redirects to the created shipment" do
        Admin::Fulfillment::Shipment.stub(:new) { mock_shipment(:save => true) }
        post :create, :shipment => {}
        response.should redirect_to(admin_fulfillment_shipment_url(mock_shipment))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved shipment as @shipment" do
        Admin::Fulfillment::Shipment.stub(:new).with({'these' => 'params'}) { mock_shipment(:save => false) }
        post :create, :shipment => {'these' => 'params'}
        assigns(:shipment).should be(mock_shipment)
      end

      it "re-renders the 'new' template" do
        Admin::Fulfillment::Shipment.stub(:new) { mock_shipment(:save => false) }
        post :create, :shipment => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested shipment" do
        Admin::Fulfillment::Shipment.should_receive(:find).with("37") { mock_shipment }
        mock_admin_fulfillment_shipment.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :shipment => {'these' => 'params'}
      end

      it "assigns the requested shipment as @shipment" do
        Admin::Fulfillment::Shipment.stub(:find) { mock_shipment(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:shipment).should be(mock_shipment)
      end

      it "redirects to the shipment" do
        Admin::Fulfillment::Shipment.stub(:find) { mock_shipment(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(admin_fulfillment_shipment_url(mock_shipment))
      end
    end

    describe "with invalid params" do
      it "assigns the shipment as @shipment" do
        Admin::Fulfillment::Shipment.stub(:find) { mock_shipment(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:shipment).should be(mock_shipment)
      end

      it "re-renders the 'edit' template" do
        Admin::Fulfillment::Shipment.stub(:find) { mock_shipment(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested shipment" do
      Admin::Fulfillment::Shipment.should_receive(:find).with("37") { mock_shipment }
      mock_admin_fulfillment_shipment.should_receive(:update_attributes)
      delete :destroy, :id => "37"
    end

    it "redirects to the admin_fulfillment_shipments list" do
      Admin::Fulfillment::Shipment.stub(:find) { mock_shipment }
      delete :destroy, :id => "1"
      response.should redirect_to(admin_fulfillment_shipments_url)
    end
  end

end
