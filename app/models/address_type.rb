# ADDRESS TYPES DOCUMENTATION
#
# The users table represents...  ADDRESS_TYPES!!!
#
# Address types are like Shipping and billing address.  This can be used to have forms
# that only show one type of address.  Following suit with amazon and many other e-commerce
# sites this field is currently not being used for addresses.  Mainly because many times it
# forces the end user to re-enter the same address twice (double the chance of an error)
# Plus in most cases is no big deal if you show an extra address to choose from in a form.

# We can take advantage of this from a data standpoint but removing this is an option.

# == Schema Information
#
# Table name: address_types
#
#  id          :integer          not null, primary key
#  name        :string(64)       not null
#  description :string(255)
#

class AddressType < ApplicationRecord
  has_many :addresses

  BILLING   = 'Billing'
  SHIPPING  = 'Shipping'
  #ORDER     = 'Order'
  NAMES     = [BILLING, SHIPPING] #, ORDER

  BILLING_ID  = 1
  SHIPPING_ID = 2
  #ORDER_ID    = 3


  validates :name, presence: true,       length: { maximum: 55 }

end
