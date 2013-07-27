class Admin::UserDatas::StoreCreditsController < Admin::UserDatas::BaseController
  helper_method :customer
  def show
    @store_credit = customer.store_credit
  end

  def edit
    form_info
  end

  def update
    if amount_to_add_is_valid?
      customer.store_credit.add_credit(amount_to_add)
      redirect_to admin_user_datas_user_store_credits_url( customer ), :notice  => "Successfully updated store credit."
    else
      customer.errors.add(:base, 'Amount must be numeric')
      form_info
      render :edit
    end
  end

  private
    def form_info

    end

    def customer
      @customer ||= User.includes(:store_credit).find(params[:user_id])
    end

    def amount_to_add_is_valid?
      params[:amount_to_add] && params[:amount_to_add].is_numeric?
    end
    def amount_to_add
      amount_to_add_is_valid? ? params[:amount_to_add].to_f : 0.0
    end

end
