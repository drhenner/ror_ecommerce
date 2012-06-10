require  'spec_helper'

describe Admin::Merchandise::Wizards::PrototypesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
    controller.session[:product_wizard] = {}
  end

  it "update action should redirect when model is valid" do
    @property = create(:property)
    @prototype = create(:prototype)
    @prototype.stubs(:properties).returns([@property])
    @prototype.stubs(:property_ids).returns([@property.id])
    #Prototype.any_instance.stubs(:find_by_id).returns(@prototype)
    put :update, :id => @prototype.id
    response.should redirect_to(admin_merchandise_wizards_brands_url)
  end
end
