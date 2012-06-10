FactoryGirl.define do
  factory :phone do
    phone_type_id   { PhoneType.first }
    phoneable       { |c| c.association(:user) }
    number          '919-636-0383'
    primary         true
  end
end
