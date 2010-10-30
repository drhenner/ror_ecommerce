
Factory.define :payment do |u|
  u.invoice         { |c| c.association(:invoice) }
  u.confirmation_id  123456789
  u.amount          315
  u.message         'test message'
  u.action          'authorization'
  u.success         true
  u.test            true
end