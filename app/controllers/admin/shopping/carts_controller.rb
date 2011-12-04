class Admin::Shopping::CartsController < Admin::Shopping::BaseController
  # GET /admin/order/carts
  # GET /admin/order/carts.xml
  def index
    authorize! :create_orders, current_user
    if f = next_admin_cart_form
      redirect_to f
    else
      @cart = session_admin_cart
      @credit_card ||= ActiveMerchant::Billing::CreditCard.new()
      respond_to do |format|
        format.html # index.html.erb
      end
    end
  end

  # GET /admin/order/carts/1
  # GET /admin/order/carts/1.xml
  def show
    @cart = Cart.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/order/carts/new
  # GET /admin/order/carts/new.xml
  def new
    @admin_shopping_cart = Cart.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end


  # POST /admin/order/carts
  # POST /admin/order/carts.xml
  def create
    @cart         =  session_admin_cart
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(cc_params)

    if @credit_card.valid?
      #ActiveRecord::Base.transaction do
        @order = Order.new_admin_cart(@cart, {:ip_address => request.remote_ip})
        response = @order.create_invoice( @credit_card,
                                          @order.credited_total,
                                          { :email            => @order.email,
                                            :billing_address  => @cart[:billing_address],
                                            :ip               => request.remote_ip },
                                          @order.amount_to_credit) if @order
      #end

      if @order && response
        if response.success?
          #clear the items out of the session_cart
          @order.remove_user_store_credits
          reset_admin_cart
          ## Render the summary with a success message
          flash[:error] = "Processed order successfully."
          render :action => "success"
        else
          render :action => "failure"
        end
      else
        flash[:error] = "Could not process the Credit Card."
        render :action => 'index' #admin_shopping_carts_url
      end
    else
      flash[:error] = "Credit Card is not valid."
      render :action => 'index'
    end

  end

  # PUT /admin/order/carts/1
  # PUT /admin/order/carts/1.xml
  def update
    @admin_shopping_cart = Cart.find(params[:id])

    respond_to do |format|
      if @admin_shopping_cart.update_attributes(params[:admin_shopping_cart])
        format.html { redirect_to(@admin_shopping_cart, :notice => 'Cart was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /admin/order/carts/1
  # DELETE /admin/order/carts/1.xml
  def destroy
    session_admin_cart = nil

    respond_to do |format|
      format.html { redirect_to(admin_shopping_carts_url) }
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