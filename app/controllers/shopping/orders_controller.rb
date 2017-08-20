class Shopping::OrdersController < Shopping::BaseController
  before_action :require_login
  # GET /shopping/orders
  ### The intent of this action is two fold
  #
  # A)  if there is a current order redirect to the process that
  # => needs to be completed to finish the order process.
  # B)  if the order is ready to be checked out...  give the order summary page.
  #
  ##### THIS METHOD IS BASICALLY A CHECKOUT ENGINE
  def index
    @order = find_or_create_order
    if f = next_form(@order)
      redirect_to f
    else
      expire_all_browser_cache
      form_info
    end
  end


  #  add checkout button
  def checkout
    #current or in-progress otherwise cart (unless cart is empty)
    order = find_or_create_order
    @order = session_cart.add_items_to_checkout(order) # need here because items can also be removed
    redirect_to next_form_url(order)
  end

  # POST /shopping/orders
  def update
    @order = find_or_create_order
    @order.ip_address = request.remote_ip

    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(cc_params)

    address = @order.bill_address.cc_params

    if !session_cart.shopping_cart_items_equal_order_items?(@order)
      flash[:alert] = I18n.t('shopping_cart_items_do_not_match_order_items')
      redirect_to shopping_cart_items_url
    elsif !@order.in_progress?
      session_cart.mark_items_purchased(@order)
      session[:order_id] = nil
      flash[:error] = I18n.t('the_order_purchased')
      redirect_to myaccount_order_url(@order)
    elsif @credit_card.valid?
      if response = @order.create_invoice(@credit_card,
                                          @order.credited_total,
                                          { email: @order.email, billing_address: address, ip: @order.ip_address },
                                          @order.amount_to_credit)
        if response.succeeded?
          expire_all_browser_cache
          ##  MARK items as purchased
          session_cart.mark_items_purchased(@order)
          session[:last_order] = @order.number
          redirect_to( confirmation_shopping_order_url(@order) ) and return
        else
          flash[:alert] =  [I18n.t('could_not_process'), I18n.t('the_order')].join(' ')
        end
      else
        flash[:alert] = [I18n.t('could_not_process'), I18n.t('the_credit_card')].join(' ')
      end
      form_info
      render :action => 'index'
    else
      form_info
      flash[:alert] = [I18n.t('credit_card'), I18n.t('is_not_valid')].join(' ')
      render :action => 'index'
    end
  end

  def confirmation
    @tab = 'confirmation'
    if session[:last_order].present? && session[:last_order] == params[:id]
      session[:last_order] = nil
      @order = Order.includes({order_items: :variant}).find_by(number: params[:id])
      render :layout => 'application'
    else
      session[:last_order] = nil
      if current_user.finished_orders.present?
        redirect_to myaccount_order_url( current_user.finished_orders.last )
      elsif current_user
        redirect_to myaccount_orders_url
      end
    end
  end
  private

  def customer_confirmation_page_view
    @tab && (@tab == 'confirmation')
  end

  def form_info
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new()
    @order.credited_total
  end

  def require_login
    if !current_user
      session[:return_to] = shopping_orders_url
      redirect_to( login_url() ) and return
    end
  end

end
