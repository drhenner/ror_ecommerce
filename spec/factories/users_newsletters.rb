# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :users_newsletter, :class => 'UsersNewsletters' do
    user_id 1
    newsletter_id 1
  end
end
