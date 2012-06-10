require 'spec_helper'
require 'test_helper'

class Admin::Fulfillment::AddressesControllerTest < ActionController::TestCase
#  context "on GET to :show for first record" do
#    setup do
#      get :show, :id => 1
#    end
#
#    should assign_to(:user)
#    should respond_with(:success)
#    should render_template(:show)
#    should_not set_the_flash
#
#    should "do something else really cool" do
#      assert_equal 1, assigns(:user).id
#    end
#  end
  
  
  
  context "GET edit" do
    before do
      admin_user = login_as(Factory.create(:admin_user))
      @address    = create(:address)
      @shipment    = create(:shipment, :address => @address)
      
      get :edit , {:shipment_id => @shipment.id, :id => @address.id }
    end
    subject { controller }
    
    should render_template "edit"

  end
end