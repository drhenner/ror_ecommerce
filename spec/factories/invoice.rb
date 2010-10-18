
Factory.define :invoice do |u|
  u.order           { |c| c.association(:order) }
  u.amount          20.13
  u.state           'authorized'
  u.active          true
  u.invoice_type    'Purchase'
end
