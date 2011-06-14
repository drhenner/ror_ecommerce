class Shopping::OrdersController < Shopping::BaseController
  # GET /shopping/orders
  # GET /shopping/orders.xml
  ### The intent of this action is two fold
  #
  # A)  if there is a current order redirect to the process that
  # => needs to be completed to finish the order process.
  # B)  if the order is ready to be checked out...  give the order summary page.
  #
  ##### THIS METHOD IS BASICALLY A CHECKOUT ENGINE
  def index
    #current or in-progress otherwise cart (unless cart is empty)
    order = find_or_create_order
    @order = session_cart.add_items_to_checkout(order) # need here because items can also be removed
    if f = next_form(@order)
      redirect_to f
    else
      @credit_card ||= ActiveMerchant::Billing::CreditCard.new()
      @order.find_total
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @orders }
      end
    end
  end

  # GET /shopping/orders/1
  # GET /shopping/orders/1.xml
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /shopping/orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /shopping/orders
  # POST /shopping/orders.xml
  def update
    @order = find_or_create_order
    @order.ip_address = request.remote_ip

    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(cc_params)
    #gateway = ActiveMerchant::Billing::PaypalGateway.new(:login=>$PAYPAL_LOGIN, :password=>$PAYPAL_PASSWORD)

    #res = gateway.authorize(amount, credit_card, :ip=>request.remote_ip, :billing_address=>billing_address)
    address = @order.bill_address.cc_params

    if @order.complete?
      #CartItem.mark_items_purchased(session_cart, @order)
      session_cart.mark_items_purchased(@order)
      flash[:error] = "The order has been purchased."
      redirect_to myaccount_order_url(@order)
    elsif @credit_card.valid?
      if response = @order.create_invoice(@credit_card,
                                          @order.credited_total,
                                          {:email => @order.email, :billing_address=> address, :ip=> @order.ip_address },
                                          @order.amount_to_credit)
        if response.succeeded?
          ##  MARK items as purchased
          #CartItem.mark_items_purchased(session_cart, @order)
          @order.remove_user_store_credits
          session_cart.mark_items_purchased(@order)
          redirect_to myaccount_order_path(@order)
        else
          flash[:error] = "Could not process the Order."
          render :action => "index"
        end
      else
        ###  Take this
        flash[:error] = "Could not process the Credit Card."
        render :action => 'index'
      end
    else
      flash[:error] = "Credit Card is not valid."
      render :action => 'index'
    end
  end

  private

  def cc_params
    {
          :type               => params[:type],
          :number             => params[:number],
          :verification_value => params[:verification_value],
          :month              => params[:month],
          :year               => params[:year],
          :first_name         => params[:first_name],
          :last_name          => params[:last_name]
    }
  end

end
