require 'spec_helper'

describe "admin_config_overviews/edit.html.erb" do
  before(:each) do
    @overview = assign(:overview, stub_model(Admin::Config::Overview,
      :new_record? => false
    ))
  end

  it "renders the edit overview form" do
    render

    rendered.should have_selector("form", :action => overview_path(@overview), :method => "post") do |form|
    end
  end
end
