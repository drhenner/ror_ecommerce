require  'spec_helper'

describe WishItemsController do
  render_views

  it "redirect to login if no current_user" do
    get :index
    response.should redirect_to(login_url)
  end
end

describe WishItemsController do
  render_views
  before(:each) do
    activate_authlogic
    @cur_user = create(:user)
    login_as(@cur_user)
    @variant = create(:variant)
    @wish_item = create(:cart_item, :item_type_id => ItemType::WISH_LIST_ID, :user_id => @cur_user.id, :variant => @variant)

  end
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "destroy action should render index template" do
    delete :destroy, :id => @wish_item.id, :variant_id => @variant.id
    CartItem.find(@wish_item.id).active.should be_false
    response.should render_template(:index)
  end
end
