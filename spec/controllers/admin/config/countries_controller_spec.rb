require  'spec_helper'

describe Admin::Config::CountriesController do
  # fixtures :all
  render_views
  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
  end
  it "index action should render index template" do
    country = Country.first
    get :index
    response.should render_template(:index)
  end

  it "edit action should render edit template" do
    country = Country.first
    get :edit, :id => country.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    country = Country.first
    Country.any_instance.stubs(:valid?).returns(false)
    put :update, :id => country.id, :country => country.attributes
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    country = Country.first
    Country.any_instance.stubs(:valid?).returns(true)
    put :update, :id => country.id, :country => country.attributes
    response.should redirect_to(admin_config_countries_url)
  end
end
