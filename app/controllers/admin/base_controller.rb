class Admin::BaseController < ApplicationController
  layout 'admin'

  before_filter :verify_admin

  def current_ability
    @current_ability ||= AdminAbility.new(current_user)
  end


  private

  def ssl_required?
    ssl_supported?
  end

  def verify_admin
    redirect_to root_url if !current_user || !current_user.admin?
  end

end