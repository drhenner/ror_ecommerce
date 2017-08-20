class WishItemsController < ApplicationController
  before_action :require_user

  def index
  end

  # DELETE /wish_items/1
  def destroy
    if params[:variant_id].present?
      item = current_user.wish_list_items.find_by(variant_id: params[:variant_id])
      item.update_attributes( active: false )
    end
    render  action: :index
  end
end
