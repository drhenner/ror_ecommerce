require  'spec_helper'

describe Admin::Config::CountriesController do
  # fixtures :all
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "update action should redirect and make the country active" do
    country = Country.first()
    country.update_attribute(:active,  false)
    Country.any_instance.stubs(:valid?).returns(true)
    put :update, :id => country.id, :country => country.attributes
    country.reload
    country.active.should be_true
    response.should redirect_to(admin_config_countries_url)
  end

  it "destroy action should make the country inactive and redirect to index action" do
    country = Country.first()
    country.update_attribute(:active,  true)
    delete :destroy, :id => country.id
    response.should redirect_to(admin_config_countries_url)
    country.reload
    country.active.should be_false
  end
end
