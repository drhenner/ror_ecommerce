# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :users_newsletter do
    user { |c| c.association(:user) }
    newsletter_id { 1 }
  end
end
