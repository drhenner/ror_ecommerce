class CartItem < ActiveRecord::Base
  belongs_to :item_type
  belongs_to :user
  belongs_to :cart
  belongs_to :variant

  # Call this if you need to know the unit price of an item
  # @return [Float] price of the variant in the cart
  def price
    self.variant.price
  end

  # Call this method if you need the price of an item before taxes
  # @return [Float] price of the variant in the cart times quantity
  def total
    self.price * self.quantity
  end

  # Call this method to soft delete an item in the cart
  # @return [Boolean]
  def inactivate!
    self.update_attributes(:active => false)
  end

  # Call this method to determine if an item is in the shopping cart and active
  # @return [Boolean]
  def shopping_cart_item?
    item_type_id == ItemType::SHOPPING_CART_ID && active?
  end

  #def self.mark_items_purchased(cart, order)
  #  CartItem.update_all("item_type_id = #{ItemType::PURCHASED_ID}", "id IN (#{cart.shopping_cart_item_ids.join(',')}) AND variant_id IN (#{order.variant_ids.join(',')})")
  #end
end
