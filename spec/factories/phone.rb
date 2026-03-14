FactoryBot.define do
  factory :phone do
    phone_type   { PhoneType.first }
    phoneable_type { 'User' }
    phoneable_id       { FactoryBot.create(:user).id }
    number { '919-636-0383' }
    primary { true }
  end
end
