# the cart is simply a bucket of stuff.  it is very well documented in a blog post I have posted:

# The first thing that comes to mind of a great cart is that it is "stupid".
# Sure that might sound crazy but it is very true. A shopping cart should not know much
# about your "order" or your "products". Your cart should simply be a bucket to keep a
# bunch of products for a specific user. It doesn't know the price of the products or
# anything about the checkout process.
#
# The second thing about a great cart is that it ironically it is "smart" about itself.
# Your cart should NOT know about the order or products but it should know about itself.
# Note your cart is the combination of a "cart model" and "cart_items model". This cart_items
# model has the following fields:
#
# cart_id
# product_id
# item_type_id
# quantity
# Additionally the cart should only have the following field:
#
# user_id     (this is the stylist user_id in the admin area)
# customer_id (for the customer facing site this == user_id)
#
#
# Also note I am in favor of adding user_id to the cart_items table to keep queries more simple.
#
# One feature I added to the minimum model is the field item_type_id. item_type_id refers to a
# model that just has a name field. The ItemTypes are as follows:
#
# shopping_cart
# save_for_later
# wish_list
# purchased
# deleted
# admin_cart
#
# What this simple field in the DB does is allows you to have a wish list and save for later
# functionality out of the box. Additionally you can WOW your marketing team by telling them
# all the items a user has ever deleted out of their cart or purchased. If you ever need to create
# a recommendation engine your cart will give you all the data you need.
#
# Now with this model, purchasing an item is simply taking the items that are in the cart and
# have an item_type of shopping_cart and moving them to an order / order_items object.  Once
# you purchase an order_item you change the cart_item.item_type to "purchased" with cart.mark_items_purchased(order)

# _______________________


# == Combining the Cart and Order Objects
#
# I've heard the argument that using an order object for the cart "make things easier".
# Not only do I disagree but sorry, "You would be wrong". By mixing the cart and the order you have not
# separated concerns. This can make validations very conditional. It also mixes cart logic with order logic.
#
# I view your cart as something that can be removed off the face of the planet and not effect much. Sure
# people would be upset to add things back to their cart but at the end of the day it would not effect anything
# financially. The order however is sacred. If an order was deleted you could lose financial data and even
# fulfillment information. Hence you don't want to be messing around with the order because you could be
# shooting yourself in the foot.
#
# By nature your cart has a lot of abandoned records. If the order and cart are separated you could very easily
# archive the carts without much worry. If your order is your cart the risk to do this would be too great.
# One small bug could cost you way too much.
#
# Now you have an extremely slim cart with a tremendous amount of functionality.

# == Removing an item
#
# The when the item is removed from the cart instead of deleting the cart_item the item is
# changed to active = false.  This allows you to see the state of the item when it was removed from the cart.
#
# == Save for later
#
# The when the item is marked for "save_for_later" in the cart now the state of the item is just changed to "save_for_later".
# So adding it back to the cart is as easy as changing the state to "shopping_cart".
#
# Take a look at [This Blog Post](http://www.ror-e.com/posts/29-e-commerce-tips-1-2-the-shopping-cart) for more details.


# == Schema Information
#
# Table name: carts
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#  customer_id :integer(4)
#

class Cart < ApplicationRecord
  belongs_to  :user
  belongs_to  :customer, class_name: 'User'
  has_many    :cart_items
  has_many    :shopping_cart_items, -> { where(active: true, item_type_id: ItemType::SHOPPING_CART_ID) },   class_name: 'CartItem'
  has_many    :saved_cart_items,    -> { where( active: true, item_type_id: ItemType::SAVE_FOR_LATER_ID) }, class_name: 'CartItem'
  has_many    :wish_list_items,     -> { where( active: true, item_type_id: ItemType::WISH_LIST_ID) },      class_name: 'CartItem'
  has_many    :purchased_items,     -> { where( active: true, item_type_id: ItemType::PURCHASED_ID) },      class_name: 'CartItem'
  has_many    :deleted_cart_items,  -> { where(active: false) }, class_name: 'CartItem'

  accepts_nested_attributes_for :shopping_cart_items

  # Adds all the item prices (not including taxes) that are currently in the shopping cart
  #
  # @param [none]
  # @return [Float] This is a float in decimal form and represents the price of all the items in the cart
  def sub_total
    shopping_cart_items.map(&:total).sum
  end

  # Adds the quantity of items that are currently in the shopping cart
  #
  # @param [none]
  # @return [Integer] Quantity all the items in the cart
  def number_of_shopping_cart_items
    shopping_cart_items.map(&:quantity).sum
  end

  # Call this method when you are checking out with the current cart items
  # => these will now be order.order_items
  # => the order can only add items if it is 'in_progress'
  #
  # @param [Order] order to insert the shopping cart variants into
  # @return [order]  return order because teh order returned has a diffent quantity
  def add_items_to_checkout(order)
    if order.in_progress?
      order.order_items.map(&:destroy)
      order.order_items.reload
      items_to_add(order, shopping_cart_items)
    end
    order
  end

  def shopping_cart_items_equal_order_items?(order)
    # cart item has quantity, but order item doesn't.
    # for example: cart and order both have two of the same item which variant_id is 1
    # cart will look like this: [{variant_id: 1, quantity: 2}]
    # order will look like this: [{variant_id: 1}, {variant_id: 1}]
    # before comparing, both need to be converted into the same style
    variant_ids_in_cart = []
    shopping_cart_items.each do |item|
      item.quantity.times do
        variant_ids_in_cart.push(item.variant_id)
      end
    end
    order_items = order.order_items.map(&:variant_id)
    variant_ids_in_cart.sort == order_items.sort
  end

  # Call this method when you want to add an item to the shopping cart
  #
  # @param [Integer, #read] variant id to add to the cart
  # @param [User, #read] user that is adding something to the cart
  # @param [Integer, #optional] ItemType id that is being added to the cart
  # @return [CartItem] return the cart item that is added to the cart
  def add_variant(variant_id, customer, qty = 1, cart_item_type_id = ItemType::SHOPPING_CART_ID, admin_purchase = false)
    items = shopping_cart_items.where(variant_id: variant_id).to_a
    variant = Variant.find_by(id: variant_id)
    quantity_to_purchase = variant.quantity_purchaseable_if_user_wants(qty.to_i, admin_purchase)
    if admin_purchase && (quantity_to_purchase > 0)
      cart_item = add_cart_items(items, quantity_to_purchase, customer, cart_item_type_id, variant_id)
    elsif variant.sold_out?
      cart_item = saved_cart_items.create(variant_id:   variant_id,
                                          user:         customer,
                                          item_type_id: ItemType::SAVE_FOR_LATER_ID,
                                          quantity:     qty
                                    ) if items.size < 1
    else
      cart_item = add_cart_items(items, quantity_to_purchase, customer, cart_item_type_id, variant_id)
    end
    cart_item
  end


  # Call this method when you want to remove an item from the shopping cart
  #   The CartItem will not delete.  Instead it is just inactivated
  #
  # @param [Integer, #read] variant id to add to the cart
  # @return [CartItem] return the cart item that is added to the cart
  def remove_variant(variant_id)
    citems = self.cart_items.each {|ci| ci.inactivate! if variant_id.to_i == ci.variant_id }
    return citems
  end

  # Call this method when you want to associate the cart with a user
  #
  # @param [User]
  def save_user(u)  # u is user object or nil
    if u && self.user_id != u.id
      self.user_id = u.id
      self.save
    end
  end

  # Call this method when you want to mark the items in the order as purchased
  #   The CartItem will not delete.  Instead the item_type changes to purchased
  #
  # @param [Order]
  def mark_items_purchased(order)
    CartItem.where(id: (self.cart_item_ids + self.shopping_cart_item_ids).uniq).
             where(variant_id: order.variant_ids).
             update_all("item_type_id = #{ItemType::PURCHASED_ID}") if !order.variant_ids.empty?
  end

  def merge_with_previous_cart!
    if user_id && previous_cart
      current_items = cart_items.map(&:variant_id)
      previous_cart.cart_items.each do |item|
        self.add_variant(item.variant_id, item.user, item.quantity) unless current_items.include?(item.variant_id)
      end
    end
  end

  def self.previous_for_user(cart_id, user_id)
    Cart.where(['id <> ?', cart_id]).where(user_id: user_id).last
  end

  private

  def previous_cart
    @previous_cart ||= Cart.previous_for_user(id, user_id)
  end

  def update_shopping_cart(cart_item,customer, qty = 1)
    if customer
      self.shopping_cart_items.find(cart_item.id).update_attributes(:quantity => (cart_item.quantity + qty), :user_id => customer.id)
    else
      self.shopping_cart_items.find(cart_item.id).update_attributes(:quantity => (cart_item.quantity + qty))
    end
  end

  def add_cart_items(items, qty, customer, cart_item_type_id, variant_id)
    if items.size < 1
      cart_item = shopping_cart_items.create(variant_id:   variant_id,
                                             user:         customer,
                                             item_type_id: cart_item_type_id,
                                             quantity:     qty
                                    )
    else
      cart_item = items.first
      update_shopping_cart(cart_item,customer, qty)
    end
    cart_item
  end

  def items_to_add(order, items)
    items.each do |item|
      order.add_cart_item( item, nil)
    end
  end

  def items_to_add_or_destroy(items_in_cart, order)
    #destroy_any_order_item_that_was_removed_from_cart
    destroy_order_items_not_in_cart!(items_in_cart, order)
   # order.order_items.delete_all #destroy(order_item.id)
    items = order.order_items.inject({}) {|h, item| h[item.variant_id].nil? ? h[item.variant_id] = [item.id]  : h[item.variant_id] << item.id; h}
    items_in_cart.each_pair do |variant_id, qty_in_cart|
      variant = Variant.find(variant_id)
      if items[variant_id].nil? # the order does not have any order_items with this variant_id
        order.add_items( variant , qty_in_cart)
      elsif qty_in_cart - items[variant_id].size > 0 # the order does not enough order_items with this variant_id
        order.add_items( variant , qty_in_cart - items[variant_id].size)
      elsif qty_in_cart - items[variant_id].size < 0 # the order has too many order_items with this variant_id
        order.remove_items( variant , qty_in_cart )
      end
    end
    order
  end
  private
    def destroy_order_items_not_in_cart!(items_in_cart, order)
      order.order_items.delete_if {|order_item| !items_in_cart.keys.any?{|variant_id| variant_id == order_item.variant_id } }
    end
end
