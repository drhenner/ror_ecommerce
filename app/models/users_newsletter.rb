class UsersNewsletter < ApplicationRecord
  belongs_to :newsletter
  belongs_to :user

  def self.unsubscribe(email, key)
    if key.present? && ActiveSupport::SecurityUtils.secure_compare(unsubscribe_key(email), key.to_s)
      user = User.find_by(email: email)
      if user
        user.users_newsletters.map(&:destroy)
      end
    end
  end

  def self.unsubscribe_key(email)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, "UFCfit-#{email.to_s}")
  end
end
