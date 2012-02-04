Factory.sequence :brand_number do |i|
  i
end

Factory.define :brand do |u|
  u.name            "Brand Name #{ Factory.next(:brand_number) }"
end
