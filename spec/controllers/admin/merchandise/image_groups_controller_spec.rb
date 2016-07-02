require  'spec_helper'

describe Admin::Merchandise::ImageGroupsController do
  # fixtures :all
  render_views
  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    image_group = FactoryGirl.create(:image_group)
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    image_group = FactoryGirl.create(:image_group)
    get :show, params: { :id => image_group.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    image_group = FactoryGirl.build(:image_group)
    ImageGroup.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :image_group => image_group.attributes.reject {|k,v| ['id', 'created_at', 'updated_at'].include?(k)} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    image_group = FactoryGirl.build(:image_group)
    ImageGroup.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :image_group => image_group.attributes.reject {|k,v| ['id', 'created_at', 'updated_at'].include?(k)} }
    expect(response).to redirect_to(edit_admin_merchandise_image_group_url(assigns[:image_group]))
  end

  it "edit action should render edit template" do
    image_group = FactoryGirl.create(:image_group)
    get :edit, params: { :id => image_group.id }
    expect(response).to render_template(:edit)
  end

end
