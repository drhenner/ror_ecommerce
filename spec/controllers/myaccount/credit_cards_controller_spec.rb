require  'spec_helper'

describe Myaccount::CreditCardsController do
  render_views

  before(:each) do
    activate_authlogic
    @user = create(:user)
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    @credit_card = create(:payment_profile, :user => @user)
    get :show, :id => @credit_card.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    PaymentProfile.any_instance.stubs(:valid?).returns(false)
    credit_card = build(:payment_profile)
    post :create, :payment_profile => credit_card.attributes
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    PaymentProfile.any_instance.stubs(:valid?).returns(false)
    PaymentProfile.any_instance.stubs(:create_payment_profile).returns(true)
    credit_card = build(:payment_profile)
    post :create, :payment_profile => credit_card.attributes#.merge(:credit_card_info)
  end

  it "edit action should render edit template" do
    @credit_card = create(:payment_profile, :user => @user)
    get :edit, :id => @credit_card.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @credit_card = create(:payment_profile, :user => @user)
    PaymentProfile.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @credit_card.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @credit_card = create(:payment_profile, :user => @user)
    PaymentProfile.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @credit_card.id
    response.should redirect_to(myaccount_credit_card_url(assigns[:credit_card]))
  end

  it "destroy action should inactivate model and redirect to index action" do
    @credit_card = create(:payment_profile, :user => @user)
    delete :destroy, :id => @credit_card.id
    response.should redirect_to(myaccount_credit_cards_url)
    PaymentProfile.exists?(@credit_card.id).should be_true

    c = PaymentProfile.find(@credit_card.id)
    c.active.should be_false
  end
end

describe Myaccount::CreditCardsController do
  render_views

  it "index action should go to login page" do
    get :index
    response.should redirect_to(login_url)
  end

  it "show action should go to login page" do
    @credit_card = create(:payment_profile)
    get :show, :id => @credit_card.id
    response.should redirect_to(login_url)
  end
end
