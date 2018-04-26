# To understand this model more please look at the documentation in the CART.rb model

# == Schema Information
#
# Table name: cart_items
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)
#  cart_id      :integer(4)
#  variant_id   :integer(4)      not null
#  quantity     :integer(4)      default(1)
#  active       :boolean(1)      default(TRUE)
#  item_type_id :integer(4)      not null
#  created_at   :datetime
#  updated_at   :datetime
#

class CartItem < ApplicationRecord
  belongs_to :item_type
  belongs_to :user
  belongs_to :cart
  belongs_to :variant

  validates :item_type_id,  presence: true
  validates :variant_id,    presence: true

  QUANTITIES = [1,2,3,4]

  before_save :inactivate_zero_quantity

  # Call this if you need to know the unit price of an item
  #
  # @param [none]
  # @return [Float] price of the variant in the cart
  def price
    self.variant.price
  end

  def name
    variant.product_name
  end

  # Call this method if you need the price of an item before taxes
  #
  # @param [none]
  # @return [Float] price of the variant in the cart times quantity
  def total
    self.price * self.quantity
  end

  # Call this method to soft delete an item in the cart
  #
  # @param [none]
  # @return [Boolean]
  def inactivate!
    self.update_attributes(active: false)
  end

  # Call this method to determine if an item is in the shopping cart and active
  #
  # @param [none]
  # @return [Boolean]
  def shopping_cart_item?
    item_type_id == ItemType::SHOPPING_CART_ID && active?
  end

  def shipping_rate
    variant.product.shipping_rate
  end

  def self.before(at)
    where( "cart_items.created_at <= ?", at )
  end

  #def self.mark_items_purchased(cart, order)
  #  CartItem.update_all("item_type_id = #{ItemType::PURCHASED_ID}", "id IN (#{cart.shopping_cart_item_ids.join(',')}) AND variant_id IN (#{order.variant_ids.join(',')})")
  #end

  private

    def inactivate_zero_quantity
      self.active = false if quantity == 0
    end
end
