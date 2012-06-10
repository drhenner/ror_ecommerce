require File.dirname(__FILE__) + '/../spec_helper'

describe ProductsController do

  before(:each) do
    @product = create(:product, :active => true)
    @variant = create(:variant, :product => @product)
    @variant.stubs(:primary_property).returns(nil)
    @variant.stubs(:properties).returns(nil)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should not blow up without a property association" do
    get :show, :id => @product.permalink
    response.should render_template(:show)
  end
end