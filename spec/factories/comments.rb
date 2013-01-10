FactoryGirl.define do
  factory :comment do
    note "My Note"
    commentable { |c| c.association(:return_authorization) }
    created_by  { |c| c.association(:user).id }
    user        { |c| c.association(:user) }
  end
end
