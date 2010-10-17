# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :return_item do |f|
  f.order_item_id 1
  f.return_condition_id 1
  f.return_reason 1
  f.returned false
  f.updated_by 1
end
