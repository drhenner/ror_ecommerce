# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :return_authorization do |f|
  f.number          "34567kjhgf"
  f.amount          "9.99"
  f.restocking_fee  "3.98"
  f.order           { |c| c.association(:order) }
  f.state           "authorized"
  f.user            { |c| c.association(:user) }
  f.created_by      { |c| c.association(:user) }
end
