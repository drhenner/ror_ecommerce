FactoryGirl.define do
  factory :user_role do
    user
    role_id Role::ADMIN_ID
  end
end
