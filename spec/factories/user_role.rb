FactoryGirl.define do
  factory :user_role do
    user_id 1
    role_id Role::ADMIN_ID
  end
end
