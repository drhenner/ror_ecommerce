require 'spec_helper'

describe Admin::Fulfillment::AddressesController do

  def mock_address(stubs={})
    @mock_address ||= mock_model(Admin::Fulfillment::Address, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all admin_fulfillment_addresses as @admin_fulfillment_addresses" do
      Admin::Fulfillment::Address.stub(:all) { [mock_address] }
      get :index
      assigns(:admin_fulfillment_addresses).should eq([mock_address])
    end
  end

  describe "GET show" do
    it "assigns the requested address as @address" do
      Admin::Fulfillment::Address.stub(:find).with("37") { mock_address }
      get :show, :id => "37"
      assigns(:address).should be(mock_address)
    end
  end

  describe "GET new" do
    it "assigns a new address as @address" do
      Admin::Fulfillment::Address.stub(:new) { mock_address }
      get :new
      assigns(:address).should be(mock_address)
    end
  end

  describe "GET edit" do
    it "assigns the requested address as @address" do
      Admin::Fulfillment::Address.stub(:find).with("37") { mock_address }
      get :edit, :id => "37"
      assigns(:address).should be(mock_address)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created address as @address" do
        Admin::Fulfillment::Address.stub(:new).with({'these' => 'params'}) { mock_address(:save => true) }
        post :create, :address => {'these' => 'params'}
        assigns(:address).should be(mock_address)
      end

      it "redirects to the created address" do
        Admin::Fulfillment::Address.stub(:new) { mock_address(:save => true) }
        post :create, :address => {}
        response.should redirect_to(admin_fulfillment_address_url(mock_address))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved address as @address" do
        Admin::Fulfillment::Address.stub(:new).with({'these' => 'params'}) { mock_address(:save => false) }
        post :create, :address => {'these' => 'params'}
        assigns(:address).should be(mock_address)
      end

      it "re-renders the 'new' template" do
        Admin::Fulfillment::Address.stub(:new) { mock_address(:save => false) }
        post :create, :address => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested address" do
        Admin::Fulfillment::Address.should_receive(:find).with("37") { mock_address }
        mock_admin_fulfillment_address.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :address => {'these' => 'params'}
      end

      it "assigns the requested address as @address" do
        Admin::Fulfillment::Address.stub(:find) { mock_address(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:address).should be(mock_address)
      end

      it "redirects to the address" do
        Admin::Fulfillment::Address.stub(:find) { mock_address(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(admin_fulfillment_address_url(mock_address))
      end
    end

    describe "with invalid params" do
      it "assigns the address as @address" do
        Admin::Fulfillment::Address.stub(:find) { mock_address(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:address).should be(mock_address)
      end

      it "re-renders the 'edit' template" do
        Admin::Fulfillment::Address.stub(:find) { mock_address(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested address" do
      Admin::Fulfillment::Address.should_receive(:find).with("37") { mock_address }
      mock_admin_fulfillment_address.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the admin_fulfillment_addresses list" do
      Admin::Fulfillment::Address.stub(:find) { mock_address }
      delete :destroy, :id => "1"
      response.should redirect_to(admin_fulfillment_addresses_url)
    end
  end

end
