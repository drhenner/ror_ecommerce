
Factory.define :phone do |u|
  u.phone_type_id   { PhoneType.first }
  u.phoneable       { |c| c.association(:user) }
  u.number          '919-636-0383'
  u.primary         true
end