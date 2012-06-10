FactoryGirl.define do
  factory :variant_property do
    description   'variant property description'
    variant       { |c| c.association(:variant) }
    property      { |c| c.association(:property) }
  end
end
