FactoryGirl.define do
  factory :phone do
    phone_type_id   { PhoneType.first }
    phoneable_type       'User'
    phoneable_id       { |c| c.association(:user).id }
    number          '919-636-0383'
    primary         true
  end
end
