class CartItem < ActiveRecord::Base
  belongs_to :item_type
  belongs_to :user
  belongs_to :cart
  belongs_to :variant
  
  
  def price
    self.variant.price
  end
  
  def total
    self.price * self.quantity
  end
  
  def inactivate!
    self.update_attributes(:active => false)
  end
  
  def shopping_cart_item?
    item_type_id == ItemType::SHOPPING_CART_ID
  end
  
  def self.mark_items_purchased(cart, order)
    CartItem.update_all("item_type_id = #{ItemType::PURCHASED_ID}", "id IN (#{cart.shopping_cart_item_ids.join(',')}) AND variant_id IN (#{order.variant_ids.join(',')})")
  end
end
