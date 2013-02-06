module CouponFirstPurchase
  def eligible?(order, at = nil )
    at ||= order.completed_at || Time.zone.now
    (starts_at <= at && expires_at >= at) && (order.user.try(:number_of_finished_orders_at, at) == 0) rescue false
  end
end
