class WishItemsController < ApplicationController
  def index
    redirect_to login_url and return unless current_user
    #@wish_list_items = current_user.wish_list_items
  end

  # DELETE /wish_items/1
  # DELETE /carts/1.xml
  def destroy
    if params[:variant_id]
      item = current_user.wish_list_items(params[:variant_id]).first
      item.update_attributes(:active => false)
    end
    render :action => :index
  end
end
