require  'spec_helper'

describe WishItemsController do
  render_views

  it "redirect to login if no current_user" do
    get :index
    expect(response).to redirect_to(login_url)
  end
end

describe WishItemsController do
  render_views
  before(:each) do
    activate_authlogic
    @cur_user   = FactoryGirl.create(:user)
    login_as(@cur_user)
    @variant    = FactoryGirl.create(:variant)
    @wish_item  = FactoryGirl.create(:cart_item, item_type_id: ItemType::WISH_LIST_ID, user_id: @cur_user.id, variant: @variant)
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "destroy action should render index template" do
    delete :destroy, params: { id: @wish_item.id, variant_id: @variant.id }
    expect(CartItem.find(@wish_item.id).active).to eq false
    expect(response).to render_template(:index)
  end
end
