
Factory.define :payment_profile do |u|
  u.user            { |c| c.association(:user) }
  u.address         { |c| c.association(:address) }
  u.payment_cim_id  123456789
  u.default         true
  u.active          true
end