require File.dirname(__FILE__) + '/../spec_helper'

describe StatesController do

  it "index action should render index template" do
    request.env["HTTP_ACCEPT"] = "application/json"
    get :index, params: { :country_id => 2 }
    assert_response :success
  end
end
