require  'spec_helper'

describe Admin::Generic::DealsController do
  # fixtures :all
  render_views

  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    deal = create(:deal)
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    deal = create(:deal)
    get :show, params: { id: deal.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    deal = FactoryGirl.build(:deal)
    Deal.any_instance.stubs(:valid?).returns(false)
    post :create, params: { deal: deal.attributes.except('id', 'deleted_at', 'created_at', 'updated_at') }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    deal = FactoryGirl.build(:deal)
    Deal.any_instance.stubs(:valid?).returns(true)
    post :create, params: { deal: deal.attributes.except('id', 'deleted_at', 'created_at', 'updated_at') }
    expect(response).to redirect_to(admin_generic_deal_url(assigns[:deal]))
  end

  it "edit action should render edit template" do
    deal = create(:deal)
    get :edit, params: { :id => deal.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    deal = FactoryGirl.create(:deal)
    Deal.any_instance.stubs(:valid?).returns(false)
    put :update, params: { id: deal.id, deal: deal.attributes.except('id', 'deleted_at', 'created_at', 'updated_at') }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    deal = FactoryGirl.create(:deal)
    Deal.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: deal.id, deal: deal.attributes.except('id', 'deleted_at', 'created_at', 'updated_at') }
    expect(response).to redirect_to(admin_generic_deal_url(assigns[:deal]))
  end

  it "destroy action should destroy model and redirect to index action" do
    deal = FactoryGirl.create(:deal)
    delete :destroy, params: { id: deal.id }
    expect(response).to redirect_to(admin_generic_deals_url)
    expect(Deal.find(deal.id).deleted_at).not_to be_nil
  end
end
