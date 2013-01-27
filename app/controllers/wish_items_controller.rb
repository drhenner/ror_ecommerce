class WishItemsController < ApplicationController
  def index
    redirect_to login_url and return unless current_user
  end

  # DELETE /wish_items/1
  def destroy
    if params[:variant_id]
      item = current_user.wish_list_items(params[:variant_id]).first
      item.update_attributes(:active => false)
    end
    render :action => :index
  end
end
