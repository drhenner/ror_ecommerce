class Customer::ActivationsController < ApplicationController

  # This method should be an "update method" but
  # I imagine some email clients will have a hard time with this.
  # plus some people will want to copy and paste the link.
  def show
    @user = User.find_by_perishable_token(params[:a])
    if @user && (@user.active? || @user.activate!)
      UserSession.create(@user, true)
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
