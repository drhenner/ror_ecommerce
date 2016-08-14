require File.dirname(__FILE__) + '/../spec_helper'

describe NotificationsController do
  render_views

  let(:user)    { FactoryGirl.create(:user) }
  let(:variant) { FactoryGirl.create(:variant) }

  before(:each) do
    activate_authlogic
    login_as(user)
  end

  it "create action should redirect to product when model is already created" do
    put :update, params: { id: variant.id }
    expect(response).to redirect_to(product_url(variant.product))
  end

  it "create action should create an InStockNotification" do
    expect {
      put :update, params: { id: variant.id }
    }.to change{ InStockNotification.count }.by(1)

    expect(response).to redirect_to(product_url(variant.product))
  end

  it "create action should redirect to product when model is already sent previously" do
    put :update, params: { id: variant.id }

    expect(response).to redirect_to(product_url(variant.product))
  end

  it "create action should redirect to product when model is already sent previously" do
    notification = FactoryGirl.create(:notification, type: InStockNotification, user: user, sent_at: Time.now - 1.day, notifiable: variant)
    put :update, params: { id: variant.id }
    notification.reload

    expect(notification.sent_at).to be nil
    expect(response).to redirect_to(product_url(variant.product))
  end
end
