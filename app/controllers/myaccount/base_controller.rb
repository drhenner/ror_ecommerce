class Myaccount::BaseController < ApplicationController
  helper_method :selected_myaccount_tab
  before_filter :require_user

  protected
  def myaccount_tab
    true
  end

  def ssl_required?
    ssl_supported?
  end

  def selected_myaccount_tab(tab)
    tab == ''
  end
end