# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :referral_program do
    active false
    description "MyText"
    name "MyString"
    referral_bonus { |c| c.association(:referral_bonus) }
  end
end
