class Myaccount::BaseController < ApplicationController

  protected

  def ssl_required?
    ssl_supported?
  end
end