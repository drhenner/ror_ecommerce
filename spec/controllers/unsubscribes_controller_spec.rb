require  'spec_helper'

describe UnsubscribesController do
  # fixtures :all
  render_views

  it "show action should render show template" do
    newsletter         = FactoryGirl.create(:newsletter, :autosubscribe => true)
    unsubscribing_user = FactoryGirl.create(:user)
    expect(unsubscribing_user.newsletter_ids.include?(newsletter.id)).to be true
    get :show, params: { email: unsubscribing_user.email, key: UsersNewsletter.unsubscribe_key(unsubscribing_user.email) }
    expect(response).to render_template(:show)
    unsubscribing_user.reload
    expect(unsubscribing_user.newsletter_ids).to eq []
  end
end
