require 'spec_helper'

describe "admin_config_overviews/new.html.erb" do
  before(:each) do
    assign(:overview, stub_model(Admin::Config::Overview,
      :new_record? => true
    ))
  end

  it "renders new overview form" do
    render

    rendered.should have_selector("form", :action => admin_config_overviews_path, :method => "post") do |form|
    end
  end
end
