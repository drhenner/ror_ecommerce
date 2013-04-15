# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :users_newsletter do
    user { |c| c.association(:user) }
    newsletter_id 1#{ Newsletter.first }
  end
end
