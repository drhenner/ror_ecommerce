class Myaccount::StoreCreditsController < Myaccount::BaseController

  def show
    @store_credit = current_user.store_credit || current_user.create_store_credit(amount: 0.0)
  end

  private

  def selected_myaccount_tab(tab)
    tab == 'store_credit'
  end

end
