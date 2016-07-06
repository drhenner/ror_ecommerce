require  'spec_helper'

describe Shopping::ShippingMethodsController do
  render_views

  before(:each) do
    activate_authlogic

    @cur_user = FactoryGirl.create(:user)
    login_as(@cur_user)

    #stylist_cart
    @variant  = FactoryGirl.create(:variant)

    create_cart(@cur_user, @cur_user, [@variant])

    @address      = FactoryGirl.create(:address)
    @order        = FactoryGirl.create(:order, :ship_address_id => @address.id)
    @order_item   = FactoryGirl.create(:order_item, :order => @order, :variant => @variant)
    @order.stubs(:order_items).returns([@order_item])
    @controller.stubs(:find_or_create_order).returns(@order)
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end
end
describe Shopping::ShippingMethodsController do
  render_views

  before(:each) do
    activate_authlogic

    @cur_user = FactoryGirl.create(:user)
    login_as(@cur_user)

    #stylist_cart
    @variant  = FactoryGirl.create(:variant)

    create_cart(@cur_user, @cur_user, [@variant])

  end
  it "update action should render edit template when model is invalid" do
    @variant2     = FactoryGirl.create(:variant)
    @address      = FactoryGirl.create(:address)
    @order        = FactoryGirl.create(:order, :ship_address => @address)
    @order_item   = FactoryGirl.create(:order_item, :order => @order, :variant => @variant)
    @order_item2   = FactoryGirl.create(:order_item, :order => @order, :variant => @variant2)
    @order.stubs(:order_items).returns([@order_item, @order_item2])
    @controller.stubs(:find_or_create_order).returns(@order)

    @shipping_rate   = FactoryGirl.create(:shipping_rate)
    @shipping_method = FactoryGirl.create(:shipping_method)
    put :update, params: { id: @shipping_method.id,
                   shipping_category: {
                    @variant.product.shipping_category_id => @shipping_rate.id,
                    @variant2.product.shipping_category_id => nil
                  } }
    expect(response).to redirect_to(shopping_shipping_methods_url)
  end

  it "update action should redirect when model is valid" do

    @address      = FactoryGirl.create(:address)
    @order        = FactoryGirl.create(:order, :ship_address => @address)
    @order_item   = FactoryGirl.create(:order_item, :order => @order, :variant => @variant)
    @order.stubs(:order_items).returns([@order_item])
    @controller.stubs(:find_or_create_order).returns(@order)

    @shipping_rate   = FactoryGirl.create(:shipping_rate)
    @shipping_method = FactoryGirl.create(:shipping_method)
    @controller.stubs(:not_secure?).returns(false)
    @controller.stubs(:next_form_url).returns(shopping_orders_url)
    ShippingMethod.any_instance.stubs(:valid?).returns(true)
    put :update, params: {id: @shipping_method.id, shipping_category: {@variant.product.shipping_category_id => @shipping_rate.id }}
    expect(response).to redirect_to(shopping_orders_url)
  end
end
