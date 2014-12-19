module UserEmailer
  extend ActiveSupport::Concern

  # email activation instructions after a user signs up
  #
  # @param  [ none ]
  # @return [ none ]
  def deliver_activation_instructions!
    if Settings.uses_resque_for_background_emails
      Resque.enqueue(Jobs::SendSignUpNotification, self.id)
    else
      Notifier.signup_notification(self.id).deliver_later
    end
  end

  def deliver_password_reset_instructions!
    self.reset_perishable_token!
    if Settings.uses_resque_for_background_emails
      Resque.enqueue(Jobs::SendPasswordResetInstructions, self.id)
    else
      Notifier.password_reset_instructions(self.id).deliver_later rescue puts( 'do nothing...  dont blow up over a password reset email')
    end
  end

end
