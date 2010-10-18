
Factory.define :transaction do |f|
  f.type      'CreditCardPurchase'
  f.batch     { |c| c.association(:batch) }
end
