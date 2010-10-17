class UserSession < Authlogic::Session::Base
  # specify configuration here, such as:
  # logout_on_timeout true
  # ...many more options in the documentation
  def to_key
     self.keys.to_a
  end
end