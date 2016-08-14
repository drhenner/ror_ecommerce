class InStockNotification < Notification
  validates :user_id, presence: true

  def self.send!(variant_ids)
    # If you want  to send to all warehouse users change the use this:
    # user_ids = User.includes(:roles).where(state: 'active').where({roles: {name: Role::WAREHOUSE} }).pluck('users.id')
    stock_notifications = InStockNotification.where(notifiable_type: 'Variant', notifiable_id: variant_ids, sent_at: nil)
    stock_notifications = stock_notifications.select{ |sn| sn.user.try(:active?) }
    user_ids            = stock_notifications.map(&:user_id)
    Notifier.in_stock_message(user_ids, Array(variant_ids)).deliver_later
    stock_notifications.each{ |sn| sn.update_attributes(sent_at: Time.zone.now) }
  end
end
