require  'spec_helper'

describe Admin::Config::TaxRatesController, type: :controller do
  render_views

  before(:each) do
    activate_authlogic
    @user = create_super_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @tax_rate = FactoryGirl.create(:tax_rate)
    get :show, params: { id: @tax_rate.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    TaxRate.any_instance.stubs(:valid?).returns(false)
    post :create, params: { tax_rate: { :start_date => Time.now.to_s(:db), :state_id => 1} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    TaxRate.any_instance.stubs(:valid?).returns(true)
    post :create, params: { tax_rate: { :start_date => Time.now.to_s(:db), :state_id => 1} }
    expect(response).to redirect_to(admin_config_tax_rate_url(assigns[:tax_rate]))
  end

  it "edit action should render edit template" do
    @tax_rate = FactoryGirl.create(:tax_rate)
    get :edit, params: { id: @tax_rate.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @tax_rate = FactoryGirl.create(:tax_rate)
    TaxRate.any_instance.stubs(:valid?).returns(false)
    put :update, params: { id: @tax_rate.id, tax_rate: { :start_date => Time.now.to_s(:db), :state_id => 1} }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @tax_rate = FactoryGirl.create(:tax_rate)
    TaxRate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: @tax_rate.id, tax_rate: { :start_date => Time.now.to_s(:db), :state_id => 1} }
    expect(response).to redirect_to(admin_config_tax_rate_url(assigns[:tax_rate]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @tax_rate = FactoryGirl.create(:tax_rate)
    delete :destroy, params: { id: @tax_rate.id }
    expect(response).to redirect_to(admin_config_tax_rates_url)
    expect(TaxRate.find(@tax_rate.id).active).to eq false
  end
end
