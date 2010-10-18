
Factory.define :cart do |u|
  u.user      { |c| c.association(:user) }
end