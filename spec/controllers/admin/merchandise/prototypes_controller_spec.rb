require  'spec_helper'

describe Admin::Merchandise::PrototypesController do
  render_views

  before(:each) do
    activate_authlogic
    @property  = FactoryGirl.create(:property)
    @user = create_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    @prototype = FactoryGirl.create(:prototype)
    get :index
    response.should render_template(:index)
  end

  it "new action should render new template" do
    Property.stubs(:all).returns([])
    get :new
    response.should redirect_to(new_admin_merchandise_property_url)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Prototype.any_instance.stubs(:valid?).returns(false)
    post :create, prototype: {:name => 'Tes', :property_ids => [@property.id]}
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    post :create, prototype: { name: 'fred', active: true, property_ids: [@property.id]}
    response.should redirect_to(admin_merchandise_prototypes_url())
    prototype = Prototype.last
    expect(prototype.property_ids).to eq [@property.id]
  end

  it "edit action should render edit template" do
    @prototype = FactoryGirl.create(:prototype)
    get :edit, :id => @prototype.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @prototype = FactoryGirl.create(:prototype)
    Prototype.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @prototype.id, :prototype => {:name => 'Tes', :property_ids => [@property.id]}
    response.should render_template(:edit)
  end
# ( :name, :active, :property_ids )
  it "update action should redirect when model is valid" do
    @prototype = FactoryGirl.create(:prototype)
    Prototype.any_instance.stubs(:valid?).returns(true)
    put :update, id: @prototype.id, prototype: {:name => 'Tes', :property_ids => [@property.id]}
    @prototype.reload
    expect(@prototype.property_ids.include?(@property.id)).to be true
    response.should redirect_to(admin_merchandise_prototypes_url())
  end

  it "destroy action should destroy model and redirect to index action" do
    @prototype = FactoryGirl.create(:prototype)
    delete :destroy, :id => @prototype.id
    response.should redirect_to(admin_merchandise_prototypes_url)
    expect(Prototype.find(@prototype.id).active).to eq false
  end
end
