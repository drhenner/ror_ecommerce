class Admin::Shopping::Checkout::OrdersController < Admin::Shopping::Checkout::BaseController
  ### The intent of this action is two fold
  #
  # A)  if there is a current order redirect to the process that
  # => needs to be completed to finish the order process.
  # B)  if the order is ready to be checked out...  give the order summary page.
  #
  ##### THIS METHOD IS BASICALLY A CHECKOUT ENGINE
  def show
    authorize! :create_orders, current_user

    @order = find_or_create_order
    #@order = session_admin_cart.add_items_to_checkout(order) # need here because items can also be removed
    if f = next_admin_order_form()
      redirect_to f
    else
      if @order.order_items.empty?
        redirect_to admin_shopping_products_url() and return
      end
      @credit_card ||= ActiveMerchant::Billing::CreditCard.new(cc_params)
    end
  end

  def start_checkout_process
    authorize! :create_orders, current_user

    order = session_admin_order
    @order = session_admin_cart.add_items_to_checkout(order) # need here because items can also be removed
    if session_admin_cart.number_of_shopping_cart_items != @order.order_items.size
      flash[:alert] = "Some items could not be added to the cart.  Out of Stock."
    end
    redirect_to next_admin_order_form_url
  end

  def update
    @order = session_admin_order
    @order.ip_address = request.remote_ip

    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(cc_params)

    address = @order.bill_address.cc_params

    if @order.complete?
      session_admin_cart.mark_items_purchased(@order)
      flash[:alert] = I18n.t('the_order_purchased')
      redirect_to admin_history_order_url(@order)
    elsif @credit_card.valid?
      if response = @order.create_invoice(@credit_card,
                                          @order.credited_total,
                                          {:email => @order.email, :billing_address=> address, :ip=> @order.ip_address },
                                          @order.amount_to_credit)
        if response.succeeded?
          order_completed!(@order)
          redirect_to admin_history_order_url(@order)
        else
          flash[:alert] =  [I18n.t('could_not_process'), I18n.t('the_order')].join(' ')
          render :action => "show"
        end
      else
        flash[:alert] = [I18n.t('could_not_process'), I18n.t('the_credit_card')].join(' ')
        render :action => 'show'
      end
    else
      flash[:alert] = [I18n.t('credit_card'), I18n.t('is_not_valid')].join(' ')
      render :action => 'show'
    end
  end

  private

  def form_info

  end

end
