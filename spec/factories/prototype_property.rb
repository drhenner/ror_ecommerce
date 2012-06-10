FactoryGirl.define do
  factory :prototype_property do
    prototype   { |c| c.association(:prototype) }
    property    { |c| c.association(:property) }
  end
end
