require  'spec_helper'

describe AboutsController, type: :controller do
  render_views

  it "show action should render show template" do
    get :show
    response.should render_template(:show)
  end
end
