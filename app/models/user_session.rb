class UserSession < Authlogic::Session::Base
  # specify configuration here, such as:
  # logout_on_timeout true
  # ...many more options in the documentation
  find_by_login_method :find_by_downcase_email
end
