# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :inventory do |f|
  f.count_on_hand             10000
  f.count_pending_to_customer 1000
  f.count_pending_from_supplier 900
end