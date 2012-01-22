require 'spec_helper'

describe "admin/config/overviews/index.html.erb" do
  before(:each) do

  end

  it "renders a list of admin_config_overviews" do
    render :template => "admin/config/overviews/index", :handlers => [:erb]
  end
end
