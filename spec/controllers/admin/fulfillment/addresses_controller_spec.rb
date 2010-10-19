require 'spec_helper'

describe Admin::Fulfillment::AddressesController do

  def mock_address(stubs={})
    @mock_address ||= mock_model(Address)#.as_null_object
    #@mock_shipment ||= mock_model(Shipment)#, stubs).as_null_object
    #@mock_shipment.stub(:shipping_addresses) { [@mock_address] }
  end
  
  def mock_shipment(stubs={})
    #@mock_address ||= mock_model(Address)#.as_null_object
    @mock_shipment ||= mock_model(Shipment)#, stubs).as_null_object
  end

  def do_get 
     get :index, :shipment_id => 23
  end
 
  ##describe "GET index" do
  #  context "on GET to :index" do
  #    #setup do
  #    before(:each) do
  #      login_as(Factory(:admin_user))
  #      @shipment    = Factory(:shipment)
  #      Shipment.should_receive(:find_fulfillment_shipment).and_return(@shipment)
  #      get :index, :shipment_id => @shipment.id
  #    end
  #
  #    #it { should assign_to(:shipment) }
  #    it { should respond_with(:success) }
  #    it { should render_template(:index) }
  #    it { should_not set_the_flash }
  #
  #    it "should assign shipment as @shipment" do
  #      assert_equal 23, assigns(:shipment).id
  #    end
  #  end
  ##end

  describe "GET edit" do
    before do
      @address    = Factory(:address)
      @shipment    = Factory(:shipment, :address => @address)
      
      admin_user = login_as(Factory.create(:admin_user))
      get :edit , {:shipment_id => @shipment.id, :id => @address.id }
    end
    subject { controller }
    
    it { should render_template "edit" }
    it { should respond_with(:success) }
    it { should assign_to(:shipment) }

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested address" do
        Address.should_receive(:find).with("37") { mock_address }
        mock_admin_fulfillment_address.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :address => {'these' => 'params'}, :shipment_id => 23
      end

      it "assigns the requested address as @address" do
        Address.stub(:find) { mock_address(:update_attributes => true) }
        put :update, :id => "1", :shipment_id => 23
        assigns(:address).should be(mock_address)
      end

      it "redirects to the address" do
        Address.stub(:find) { mock_address(:update_attributes => true) }
        put :update, :id => "1", :shipment_id => 23
        response.should redirect_to(admin_fulfillment_address_url(mock_address))
      end
    end

    describe "with invalid params" do
      it "assigns the address as @address" do
        Address.stub(:find) { mock_address(:update_attributes => false) }
        put :update, :id => "1", :shipment_id => 23
        assigns(:address).should be(mock_address)
      end

      it "re-renders the 'edit' template" do
        Address.stub(:find) { mock_address(:update_attributes => false) }
        put :update, :id => "1", :shipment_id => 23
        response.should render_template("edit")
      end
    end

  end

end
