
Factory.define :store_credit do |u|
  u.amount          0.0
  u.user            { |c| c.association(:user) }
end