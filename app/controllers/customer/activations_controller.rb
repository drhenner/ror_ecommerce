class Customer::ActivationsController < ApplicationController

  # This method should be an "update method" but
  # I imagine some email clients will have a hard time with this.
  # plus some people will want to copy and paste the link.
  def show
    @user = User.find_by_perishable_token(params[:a])
    if @user && (@user.active? || @user.activate!)
      UserSession.create(@user, true)
      cookies[:hadean_uid] = @user.access_token
      session[:authenticated_at] = Time.now.to_i
      set_user_to_cart_items(@user)
      merge_carts
      flash[:notice] = "Welcome back #{@user.name}"
    else
      flash[:notice] = "Invalid Activation URL!"
    end
    redirect_to root_url
  end

  private

  def form_info

  end
end
