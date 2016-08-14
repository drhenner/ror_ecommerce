class LowStockNotification < Notification
  validate :ensure_admin, on: :create

  class << self

    def send!(variant_ids)
      Notifier.low_stock_message(low_stock_user_ids(variant_ids), Array(variant_ids)).deliver_later
    end

    private
      # just send to specific users if this is setup
      # else send to warehouse users if created
      # else send to the admin users
      def low_stock_user_ids(variant_ids)
        variant_user_ids(variant_ids).presence || warehouse_user_ids.presence || admin_user_ids
      end

      def variant_user_ids(variant_ids)
        stock_notifications = LowStockNotification.where(notifiable_type: 'Variant', notifiable_id: variant_ids)
        stock_notifications = stock_notifications.select{ |sn| sn.user.try(:active?) && sn.user.try(:admin?) }
        stock_notifications.map(&:user_id)
      end

  end
end
