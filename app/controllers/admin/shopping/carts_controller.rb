class Admin::Shopping::CartsController < Admin::Shopping::BaseController

  # GET /admin/order/carts
  def index
    authorize! :create_orders, current_user
    if f = next_admin_cart_form
      redirect_to f
    else
      @cart = session_admin_cart
      @credit_card ||= ActiveMerchant::Billing::CreditCard.new()
    end
  end

  # DELETE /admin/order/carts/1
  def destroy
    session_admin_cart = nil
    redirect_to(admin_shopping_carts_url)
  end


  private

  def cc_params
    {
          :brand              => params[:type],
          :number             => params[:number],
          :verification_value => params[:verification_value],
          :month              => params[:month],
          :year               => params[:year],
          :first_name         => params[:first_name],
          :last_name          => params[:last_name]
    }
  end
end
