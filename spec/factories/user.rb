
Factory.sequence :email do |n|
  "person#{n}@example.com"
end
# USER

FactoryGirl.define do
  factory :user do
    first_name  'John'
    last_name   'Doe'
    email       { Factory.next(:email) }
    password              'pasword'
    password_confirmation "pasword"
    after_build {|user| user.send(:initialize_state_machines, :dynamic => :force)}
  end

  factory :registered_user, :parent => :user do
    state    'registered'
    birth_date  Time.now.to_date
  end
  factory :registered_user_with_credit, :parent => :registered_user do
    state    'registered_with_credit'
  end
end








Factory.define :admin_user, :parent => :user do |f|
  f.roles     { [Role.find_by_name('administrator')] }
end

Factory.define :super_admin_user, :parent => :user do |f|
  f.roles     { [Role.find_by_name('super_administrator')] }
end
