
Factory.define :variant_property do |f|
  f.description   'variant property description'
  f.variant       { |c| c.association(:variant) }
  f.property      { |c| c.association(:property) }
end
