# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :return_item do |f|
  f.order_item       { |c| c.association(:order_item) }
  f.return_condition { |c| c.association(:return_condition) }
  f.return_reason    { |c| c.association(:return_reason) }
  f.returned false
  f.updated_by 1
end
