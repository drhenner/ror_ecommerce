
Factory.define :purchase_order do |u|
  u.invoice_number 'John'
  u.tracking_number nil
  u.ordered_at            { Time.now }
  
  u.estimated_arrival_on  { Time.now.to_date }
end