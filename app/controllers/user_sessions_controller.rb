class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
    @user = User.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      cookies[:hadean_uid] = @user_session.record.access_token
      session[:authenticated_at] = Time.now
      cookies[:insecure] = false
      ## if there is a cart make sure the user_id is correct
      set_user_to_cart_items
      flash[:notice] = I18n.t('login_successful')
      redirect_back_or_default root_url
    else
      @user = User.new
      redirect_to login_url, :alert => I18n.t('login_failure')
    end
  end

  def destroy
    current_user_session.destroy
    reset_session
    cookies.delete(:hadean_uid)
    redirect_to login_url, :notice => I18n.t('logout_successful')
  end

  private

  def set_user_to_cart_items
    if session_cart.user_id != @user_session.record.id
      session_cart.update_attributes(:user_id => @user_session.record.id )
    end
    session_cart.cart_items.each do |item|
      item.update_attributes(:user_id => @user_session.record.id ) if item.user_id != @user_session.record.id
    end
  end
end
