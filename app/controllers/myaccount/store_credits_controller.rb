class Myaccount::StoreCreditsController < Myaccount::BaseController

  def show
    @store_credit = current_user.store_credit
  end

  private

  def form_info

  end

    def selected_myaccount_tab(tab)
      tab == 'store_credit'
    end
end
