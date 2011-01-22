class Myaccount::StoreCreditsController < ApplicationController

  before_filter :require_user

  def show
    @store_credit = current_user.store_credit
  end

  private

  def form_info

  end
end
