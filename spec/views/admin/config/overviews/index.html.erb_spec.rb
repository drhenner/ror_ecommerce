require 'spec_helper'

describe "admin_config_overviews/index.html.erb" do
  before(:each) do
    assign(:admin_config_overviews, [
      stub_model(Admin::Config::Overview),
      stub_model(Admin::Config::Overview)
    ])
  end

  it "renders a list of admin_config_overviews" do
    render
  end
end
