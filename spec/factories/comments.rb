# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :comment do |f|
  f.note "My Note"
  #f.commentable_type "MyString"
  f.commentable { |c| c.association(:return_authorization) }
  f.created_by  { |c| c.association(:user) }
  f.user        { |c| c.association(:user) }
end
