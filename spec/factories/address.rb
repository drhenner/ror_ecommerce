

# first_name  { Sham.name }
# last_name   { Sham.name }
# address1    { Sham.address }
# city        { Sham.city }
# state       { State.first }#,       :if => Proc.new { |address| address.state_name.blank?  }
# state_name   nil #,  :if => Proc.new { |address| address.state_id.blank?   }
# #zip_code    { Sham.zipcode }
# phone       { Sham.phone_number }

Factory.define :address do |u|
  u.first_name 'John'
  u.last_name  'Doe'
  u.address1  '112 south park street'
  u.city       'Fredville'
  u.state     { State.first }
  u.zip_code  '54322'
  u.address_type { AddressType.first}
end