# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :return_item do |f|
  f.order_item       { |c| c.association(:order_item) }
  f.return_condition { ReturnCondition.first }
  f.return_reason    { ReturnReason.first }
  f.return_authorization { |c| c.association(:return_authorization) }
  f.returned false
  f.updated_by 1
end
