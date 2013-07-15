require  'spec_helper'

describe Admin::Reports::WeeklyChartsController do
  render_views
  before(:each) do
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    RorEReports::Sales.any_instance.stubs(:weekly_summary).returns(fake_sales_data)
    get :index, format: :json
    expect(response).to render_template(:index)
    expect(response.body).to eq fake_sales_data.to_json
  end

  def fake_sales_data
    [
      { date: '2013-03', amount: 20, sales: 4 },
      { date: '2013-04', amount: 10, sales: 2 },
      { date: '2013-05', amount: 5,  sales: 1 },
      { date: '2013-06', amount: 5,  sales: 2 },
      { date: '2013-07', amount: 20, sales: 5 }
    ]
  end

end
