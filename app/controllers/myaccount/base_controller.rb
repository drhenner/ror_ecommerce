class Myaccount::BaseController < ApplicationController

  before_filter :require_user

  protected

  def ssl_required?
    ssl_supported?
  end
end