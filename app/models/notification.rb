# Notification Documentation
#
# The notification table provides support for handling notifications throughout the application.
# It has a polymorphic relation so can be utilised by various models.
# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  type            :string           not null
#  notifiable_id   :integer
#  notifiable_type :string
#  send_at         :datetime
#  sent_at         :datetime
#  created_at      :datetime         not null
#
# Types:
# LowStockNotification   => Notify Admin that stock is low
# OutOfStockNotification => Notify Admin that we are out of stock
# InStockNotification    => Notify User a variant is now in stock

class Notification < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: { scope: [:type, :notifiable_id, :notifiable_type, :sent_at],
                                    message: 'notification has already been created.' }


  validates :notifiable_id,   presence: true
  validates :notifiable_type, presence: true

  belongs_to :notifiable, polymorphic: true

  def self.send!
    raise 'implement me'
  end

  class << self
    private

    def warehouse_user_ids
      @warehouse_user_ids ||= User.includes(:roles).where(state: 'active').where({roles: {name: Role::WAREHOUSE} }).pluck('users.id')
    end

    def admin_user_ids
      @admin_user_ids ||= User.includes(:roles).where(state: 'active').where({roles: {name: Role::ADMIN} }).pluck('users.id')
    end
  end

  private

  def ensure_admin
    user.admin?
    unless user.admin?
      errors.add :user_id, "User must be an admin to receive stock notifications."
      false
    end
  end
end
