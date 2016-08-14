# first_name  { Sham.name }
# last_name   { Sham.name }
# address1    { Sham.address }
# city        { Sham.city }
# state       { State.first }#,       :if => Proc.new { |address| address.state_name.blank?  }
# state_name   nil #,  :if => Proc.new { |address| address.state_id.blank?   }
# #zip_code    { Sham.zipcode }
# phone       { Sham.phone_number }

FactoryGirl.define do
  factory :address do
    first_name 'John'
    last_name  'Doe'
    address1  '112 south park street'
    city       'Fredville'
    state     { State.first }
    zip_code  '54322'
    address_type { AddressType.first }
    addressable  { |c| c.association(:user) }
  end
end


#Factory.define :order_address, :parent => :address do |f|

#end
