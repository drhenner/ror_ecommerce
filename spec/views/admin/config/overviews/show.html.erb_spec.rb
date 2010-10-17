require 'spec_helper'

describe "admin_config_overviews/show.html.erb" do
  before(:each) do
    @overview = assign(:overview, stub_model(Admin::Config::Overview))
  end

  it "renders attributes in <p>" do
    render
  end
end
