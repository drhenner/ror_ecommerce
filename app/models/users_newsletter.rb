class UsersNewsletter < ApplicationRecord
  require 'digest'
  belongs_to :newsletter
  belongs_to :user

  def self.unsubscribe(email, key)
    if unsubscribe_key(email) == key
      user = User.find_by(email: email)
      if user
        user.users_newsletters.map(&:destroy)
      end
    end
  end

  def self.unsubscribe_key(email)
    sha256 = Digest::SHA256.new
    Base64.encode64(sha256.digest "UFCfit-#{email.to_s}")
  end
end
