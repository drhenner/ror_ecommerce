# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :return_authorization do |f|
  f.number "MyString"
  f.amount "9.99"
  f.restocking_fee "9.99"
  f.order_id 1
  f.state "MyString"
  f.created_by 1
end
