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
    shopping_cart_items.includes(:variant).inject(0) {|sum, item| item.total + sum}
  end
  
  def add_items_to_checkout(order)
    if order.in_progress?
      items = shopping_cart_items.inject({}) {|h, item| h[item.variant_id] = item.quantity; h}
      items_to_add_or_destroy(items, order.order_items)
      
    end
  end
  
  def items_to_add_or_destroy(items_in_cart, order_items)
    items = order_items.inject({}) {|h, item| h[item.variant_id].nil? ? h[item.variant_id] = [item.id]  : h[item.variant_id] << item.id; h}
    items.each_pair do |variant_id, array_of_order_items|
      if items_in_cart[variant_id].nil?
        # these items arent in the cart...  delete them
        OrderItem.destroy_all("id IN (?)", array_of_order_items)
      elsif items_in_cart[variant_id] > array_of_order_items.size ## the number in the cart is larger than the amount in order_items
        ###  add more to the cart
        variant = Variant.find(variant_id)
        order.add_items( variant , (items_in_cart[k] - array_of_order_items.size))
      elsif items_in_cart[variant_id] < array_of_order_items.size ## the number in the cart is smaller than the amount in order_items
        #remove items in cart
        qty_to_remove = array_of_order_items.size - items_in_cart[variant_id]  
        
        array_of_order_items.each_with_index do |item, i|
          OrderItem.destroy(item)
          break if i+1 == qty_to_remove
        end
      end
    end
    
  end
  
  def add_variant(variant_id, customer, cart_item_type_id = ItemType::SHOPPING_CART_ID)# customer is a user
    items = shopping_cart_items.find_all_by_variant_id(variant_id)
    variant = Variant.find(variant_id)
    unless variant.sold_out?
      if items.size < 1
        cart_item = cart_items.create(:variant_id   => variant_id,
                                      :user         => customer,
                                      :item_type_id => cart_item_type_id,
                                      :quantity     => 1#,#:price      => variant.price
                                      )
      else
        cart_item = items.first
        update_cart(cart_item,customer)
      end
    else
      cart_item = cart_items.create(:variant_id   => variant_id,
                                    :user         => customer,
                                    :item_type_id => ItemType::SAVE_FOR_LATER_ID,
                                    :quantity     => 1#,#:price      => variant.price
                                    ) if items.size < 1
      
    end
    cart_item
  end
  
  def remove_variant(variant_id)
    ci = cart_items.find_by_variant_id(variant_id)
    ci.inactivate!
    return ci
  end
  
  def save_user(u)  # u is user object or nil
    if u && self.user_id != u.id
      self.user_id = u.id
      self.save
    end
  end
  
  def cart_item_ids
    shopping_cart_items.collect {|cart_item| cart_item.id}
  end
  
  private
  def update_cart(cart_item,customer)
    if customer
      cart_item.update_attributes(:quantity => (cart_item.quantity + 1), :user_id => customer.id)
    else
      cart_item.update_attributes(:quantity => (cart_item.quantity + 1))
    end
  end
end
