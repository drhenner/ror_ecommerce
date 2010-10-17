# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :comment do |f|
  f.note "MyText"
  f.commentable_type "MyString"
  f.commentable_id 1
  f.created_by 1
  f.user_id 1
end
