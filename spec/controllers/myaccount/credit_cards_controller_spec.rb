require  'spec_helper'

describe Myaccount::CreditCardsController do
  render_views

  before(:each) do
    activate_authlogic
    @user = FactoryGirl.create(:user)
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @credit_card = FactoryGirl.create(:payment_profile, user: @user)
    get :show, params: {id: @credit_card.id}
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    PaymentProfile.any_instance.stubs(:valid?).returns(false)
    credit_card = FactoryGirl.build(:payment_profile)
    post :create, params: {credit_card: credit_card.attributes}
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    PaymentProfile.any_instance.stubs(:valid?).returns(false)
    PaymentProfile.any_instance.stubs(:create_payment_profile).returns(true)
    credit_card = FactoryGirl.build(:payment_profile)
    post :create, params: {credit_card: credit_card.attributes}#.merge(:credit_card_info)
  end

  it "edit action should render edit template" do
    @credit_card = FactoryGirl.create(:payment_profile, user: @user)
    get :edit, params: {id: @credit_card.id}
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @credit_card = FactoryGirl.create(:payment_profile, user: @user)
    PaymentProfile.any_instance.stubs(:valid?).returns(false)
    put :update, params: {id: @credit_card.id, credit_card: @credit_card.attributes}
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @credit_card = FactoryGirl.create(:payment_profile, user: @user)
    PaymentProfile.any_instance.stubs(:valid?).returns(true)
    put :update, params: {id: @credit_card.id, credit_card: @credit_card.attributes}
    expect(response).to redirect_to(myaccount_credit_card_url(assigns[:credit_card]))
  end

  it "destroy action should inactivate model and redirect to index action" do
    @credit_card = FactoryGirl.create(:payment_profile, user: @user)
    delete :destroy, params: {id: @credit_card.id}
    expect(response).to redirect_to(myaccount_credit_cards_url)
    expect(PaymentProfile.exists?(@credit_card.id)).to be true

    c = PaymentProfile.find(@credit_card.id)
    expect(c.active).to eq false
  end
end

describe Myaccount::CreditCardsController do
  render_views

  it "index action should go to login page" do
    get :index
    expect(response).to redirect_to(login_url)
  end

  it "show action should go to login page" do
    @credit_card = FactoryGirl.create(:payment_profile)
    get :show, params: {id: @credit_card.id}
    expect(response).to redirect_to(login_url)
  end
end
