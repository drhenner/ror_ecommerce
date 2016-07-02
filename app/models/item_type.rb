class ItemType < ApplicationRecord
  has_many :cart_items

  SHOPPING_CART   = 'shopping_cart'
  SAVE_FOR_LATER  = 'save_for_later'
  WISH_LIST       = 'wish_list'
  PURCHASED       = 'purchased'
  NAMES = [SHOPPING_CART, SAVE_FOR_LATER, WISH_LIST, PURCHASED]


  SHOPPING_CART_ID   = 1
  SAVE_FOR_LATER_ID  = 2
  WISH_LIST_ID       = 3
  PURCHASED_ID       = 4

  validates :name,        presence: true,       length: { maximum: 55 }

end
