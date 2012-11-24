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

class Cart < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :customer, :class_name => 'User'
  has_many    :cart_items
  has_many    :shopping_cart_items,       :conditions => ['cart_items.active = ? AND
                                                          cart_items.item_type_id = ?', true, ItemType::SHOPPING_CART_ID],
                                          :class_name => 'CartItem'


  has_many    :saved_cart_items,          :conditions => ['cart_items.active = ? AND
                                                          cart_items.item_type_id = ?', true, ItemType::SAVE_FOR_LATER_ID],
                                          :class_name => 'CartItem'
  has_many    :wish_list_items,           :conditions => ['cart_items.active = ? AND
                                                          cart_items.item_type_id = ?', true, ItemType::WISH_LIST_ID],
                                          :class_name => 'CartItem'

  has_many    :purchased_items,           :conditions => ['cart_items.active = ? AND
                                                          cart_items.item_type_id = ?', true, ItemType::PURCHASED_ID],
                                          :class_name => 'CartItem'

  has_many    :deleted_cart_items,        :conditions => ['cart_items.active = ?', false], :class_name => 'CartItem'

  accepts_nested_attributes_for :shopping_cart_items

  # Adds all the item prices (not including taxes) that are currently in the shopping cart
  #
  # @param [none]
  # @return [Float] This is a float in decimal form and represents the price of all the items in the cart
  def sub_total
    shopping_cart_items.inject(0) {|sum, item| item.total + sum} #.includes(:variant)
  end

  # Call this method when you are checking out with the current cart items
  # => these will now be order.order_items
  # => the order can only add items if it is 'in_progress'
  #
  # @param [Order] order to insert the shopping cart variants into
  # @return [order]  return order because teh order returned has a diffent quantity
  def add_items_to_checkout(order)
    if order.in_progress?
      order.order_items.size.times do
        item = order.order_items.pop
        item.destroy
      end
      items_to_add(order, shopping_cart_items)
    end
    order
  end

  # Call this method when you want to add an item to the shopping cart
  #
  # @param [Integer, #read] variant id to add to the cart
  # @param [User, #read] user that is adding something to the cart
  # @param [Integer, #optional] ItemType id that is being added to the cart
  # @return [CartItem] return the cart item that is added to the cart
  def add_variant(variant_id, customer, qty = 1, cart_item_type_id = ItemType::SHOPPING_CART_ID, admin_purchase = false)
    items = shopping_cart_items.find_all_by_variant_id(variant_id)
    variant = Variant.find(variant_id)
    quantity_to_purchase = (variant.quantity_purchaseable(admin_purchase) < qty.to_i) ? variant.quantity_purchaseable(admin_purchase) : qty.to_i # if we have less than desired instock

    if admin_purchase && (quantity_to_purchase > 0)
      cart_item = add_cart_items(items, quantity_to_purchase, customer, cart_item_type_id, variant_id)
    elsif variant.sold_out?
      cart_item = saved_cart_items.create(:variant_id   => variant_id,
                                    :user         => customer,
                                    :item_type_id => ItemType::SAVE_FOR_LATER_ID,
                                    :quantity     => qty#,#:price      => variant.price
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
    CartItem.update_all("item_type_id = #{ItemType::PURCHASED_ID}",
                        "id IN (#{(self.cart_item_ids + self.shopping_cart_item_ids).uniq.join(',')}) AND variant_id IN (#{order.variant_ids.join(',')})") if !order.variant_ids.empty?
  end

  private
  def update_shopping_cart(cart_item,customer, qty = 1)
    if customer
      self.shopping_cart_items.find(cart_item.id).update_attributes(:quantity => (cart_item.quantity + qty), :user_id => customer.id)
    else
      self.shopping_cart_items.find(cart_item.id).update_attributes(:quantity => (cart_item.quantity + qty))
    end
  end

  def add_cart_items(items, qty, customer, cart_item_type_id, variant_id)
    if items.size < 1
      cart_item = shopping_cart_items.create(:variant_id   => variant_id,
                                    :user         => customer,
                                    :item_type_id => cart_item_type_id,
                                    :quantity     => qty#,#:price      => variant.price
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
    order.order_items.delete_if {|order_item| !items_in_cart.keys.any?{|variant_id| variant_id == order_item.variant_id } }
   # order.order_items.delete_all #destroy(order_item.id)
    items = order.order_items.inject({}) {|h, item| h[item.variant_id].nil? ? h[item.variant_id] = [item.id]  : h[item.variant_id] << item.id; h}
    items_in_cart.each_pair do |variant_id, qty_in_cart|
      variant = Variant.find(variant_id)
      if items[variant_id].nil?
        order.add_items( variant , qty_in_cart)
      elsif qty_in_cart - items[variant_id].size > 0
        order.add_items( variant , qty_in_cart - items[variant_id].size)
      elsif qty_in_cart - items[variant_id].size < 0
        order.remove_items( variant , qty_in_cart )
      end
    end
    order
  end
end
