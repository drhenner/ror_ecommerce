require  'spec_helper'

describe Admin::Config::CountriesController, type: :controller do
  # fixtures :all
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

  it "update action should redirect and update shipping zone" do
    country = Country.first()
    country.update_attribute(:shipping_zone_id, nil)
    Country.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: country.id, country: {:shipping_zone_id => 1} }
    country.reload
    expect(country.shipping_zone_id).to eq 1
    expect(response).to redirect_to(admin_config_countries_url)
  end

  it "activate action should redirect and make the country active" do
    country = Country.first()
    country.update_attribute(:active,  false)
    Country.any_instance.stubs(:valid?).returns(true)
    put :activate, params: { id: country.id, country: country.attributes }
    country.reload
    expect(country.active).to be true
    expect(response).to redirect_to(admin_config_countries_url)
  end

  it "destroy action should make the country inactive and redirect to index action" do
    country = Country.first()
    country.update_attribute(:active,  true)
    delete :destroy, params: { id: country.id }
    expect(response).to redirect_to(admin_config_countries_url)
    country.reload
    expect(country.active).to eq false
  end
end
