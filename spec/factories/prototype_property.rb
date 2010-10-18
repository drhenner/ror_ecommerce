
Factory.define :prototype_property do |u|
  u.prototype   { |c| c.association(:prototype) }
  u.property    { |c| c.association(:property) }
end