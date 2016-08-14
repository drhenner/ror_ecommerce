class NotificationsController < ApplicationController
  before_action :require_user

  def update
    @notification = InStockNotification.where(user_id: current_user.id, notifiable: variant).first_or_create()
    @notification.update_attribute(:sent_at, nil) if @notification.sent_at?
    redirect_to product_url(variant.product), notice: "You will be notified when the item is back in stock."
  end

  private

  def variant
    @variant ||= Variant.find(params[:id])
  end

end
