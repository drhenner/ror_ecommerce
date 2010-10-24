class Cart < ActiveRecord::Base
  belongs_to  :user
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
  
  validates :user_id,  :presence => true
  
  def sub_total
    shopping_cart_items.inject(0) {|sum, item| item.total + sum} #.includes(:variant)
  end
  
  def add_items_to_checkout(order)
    if order.in_progress?
      items = shopping_cart_items.inject({}) {|h, item| h[item.variant_id] = item.quantity; h}
      items_to_add_or_destroy(items, order)
    end
  end
  
  def add_variant(variant_id, customer, cart_item_type_id = ItemType::SHOPPING_CART_ID)# customer is a user
    items = shopping_cart_items.find_all_by_variant_id(variant_id)
    variant = Variant.find(variant_id)
    unless variant.sold_out?
      if items.size < 1
        cart_item = shopping_cart_items.create(:variant_id   => variant_id,
                                      :user         => customer,
                                      :item_type_id => cart_item_type_id,
                                      :quantity     => 1#,#:price      => variant.price
                                      )
      else
        cart_item = items.first
        update_shopping_cart(cart_item,customer)
      end
    else
      cart_item = saved_cart_items.create(:variant_id   => variant_id,
                                    :user         => customer,
                                    :item_type_id => ItemType::SAVE_FOR_LATER_ID,
                                    :quantity     => 1#,#:price      => variant.price
                                    ) if items.size < 1
      
    end
    cart_item
  end
  
  def remove_variant(variant_id)
    citems = self.cart_items.each {|ci| ci.inactivate! if variant_id == ci.variant_id }
    return citems
  end
  
  def save_user(u)  # u is user object or nil
    if u && self.user_id != u.id
      self.user_id = u.id
      self.save
    end
  end
  
  def mark_items_purchased(order)
    CartItem.update_all("item_type_id = #{ItemType::PURCHASED_ID}", 
                        "id IN (#{(self.cart_item_ids + self.shopping_cart_item_ids).uniq.join(',')}) AND variant_id IN (#{order.variant_ids.join(',')})") if !order.variant_ids.empty?
  end
  
  private
  def update_shopping_cart(cart_item,customer)
    if customer
      self.shopping_cart_items.find(cart_item.id).update_attributes(:quantity => (cart_item.quantity + 1), :user_id => customer.id)
    else      
      self.shopping_cart_items.find(cart_item.id).update_attributes(:quantity => (cart_item.quantity + 1))
    end
  end
  
  def items_to_add_or_destroy(items_in_cart, order)
    #destroy_any_order_item_that_was_removed_from_cart
    order.order_items.delete_if {|order_item| !items_in_cart.keys.any?{|variant_id| variant_id == order_item.variant_id } }
   # order.order_items.delete_all #destroy(order_item.id) 
    
    items = order.order_items.inject({}) {|h, item| h[item.variant_id].nil? ? h[item.variant_id] = [item.id]  : h[item.variant_id] << item.id; h}
    
    items_in_cart.each_pair do |variant_id, qty_in_cart|
      if items[variant_id].nil?
        variant = Variant.find(variant_id)
        order.add_items( variant , qty_in_cart)
      elsif qty_in_cart - items[variant_id].size > 0
        order.add_items( variant , qty - items[variant_id])
      elsif qty_in_cart - items[variant_id].size < 0
        raise errooor
        order.remove_items( variant , qty_in_cart - items[variant_id])
      end
    end
  end
end
