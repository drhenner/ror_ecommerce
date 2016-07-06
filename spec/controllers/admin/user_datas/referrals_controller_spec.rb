require  'spec_helper'

describe Admin::UserDatas::ReferralsController do
  # fixtures :all
  render_views

  before(:each) do
    activate_authlogic
    @cur_user = FactoryGirl.create(:admin_user)
    login_as(@cur_user)
  end

  it "index action should render index template" do
    referral = FactoryGirl.create(:referral)
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    referral = FactoryGirl.create(:referral)
    get :show, params: { id: referral.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    referral = FactoryGirl.build(:referral)
    Referral.any_instance.stubs(:valid?).returns(false)
    post :create, params: {referral: referral.attributes.reject {|k,v| ['id','applied','clicked_at','purchased_at', 'referral_user_id', 'referring_user_id', 'registered_at','sent_at', 'created_at', 'updated_at'].include?(k)}}
    expect(response).to render_template(:new)
  end

  it "create action should render new template when wrong email given " do
    @ref_user = FactoryGirl.create(:user)
    referral = FactoryGirl.build(:referral)
    Referral.any_instance.stubs(:valid?).returns(true)
    post :create, params: { referral: referral.attributes.reject {|k,v| ['id','applied','clicked_at','purchased_at', 'referral_user_id', 'referring_user_id', 'registered_at','sent_at', 'created_at', 'updated_at'].include?(k)}, referring_user_email: 'blah' }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @ref_user = FactoryGirl.create(:user)
    referral = FactoryGirl.build(:referral)
    Referral.any_instance.stubs(:valid?).returns(true)
    post :create, params: { referral: referral.attributes.reject {|k,v| ['id','applied','clicked_at','purchased_at', 'referral_user_id', 'referring_user_id', 'registered_at','sent_at', 'created_at', 'updated_at'].include?(k)}, referring_user_email: @ref_user.email}
    expect(response).to redirect_to(admin_user_datas_referral_url(assigns[:referral]))
  end

  it "edit action should render edit template" do
    referral = FactoryGirl.create(:referral)
    get :edit, params: { id: referral.id}
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    referral = FactoryGirl.create(:referral)
    Referral.any_instance.stubs(:valid?).returns(false)
    put :update, params: { id: referral.id, referral: referral.attributes.reject {|k,v| ['id','applied','clicked_at','purchased_at', 'referral_user_id', 'referring_user_id', 'registered_at','sent_at', 'created_at', 'updated_at'].include?(k)}}
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    referral = FactoryGirl.create(:referral)
    Referral.any_instance.stubs(:valid?).returns(true)
    put :update, params: {id: referral.id, referral: referral.attributes.reject {|k,v| ['id','applied','clicked_at','purchased_at', 'referral_user_id', 'referring_user_id', 'registered_at','sent_at', 'created_at', 'updated_at'].include?(k)}}
    expect(response).to redirect_to(admin_user_datas_referral_url(assigns[:referral]))
  end

  it "destroy action should destroy model and redirect to index action" do
    referral = FactoryGirl.create(:referral)
    delete :destroy, params: { id: referral.id }
    expect(response).to redirect_to(admin_user_datas_referrals_url)
    expect(Referral.exists?(referral.id)).to eq false
  end
end
