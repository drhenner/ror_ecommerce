class Admin::Shopping::CreditCardsController < Admin::Shopping::BaseController
  # GET /admin/order/credit_cards
  # GET /admin/order/credit_cards.xml
  def index
    @credit_cards = session_admin_cart[:user].credit_cards.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/order/credit_cards/1
  # GET /admin/order/credit_cards/1.xml
  def show
    @credit_card = session_admin_cart[:user].credit_cards.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/order/credit_cards/new
  # GET /admin/order/credit_cards/new.xml
  def new
    @credit_card = CreditCard.new(:user_id => session_admin_cart[:user].id)

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /admin/order/credit_cards
  # POST /admin/order/credit_cards.xml
  def create
    @credit_card = session_admin_cart[:user].credit_cards.new(params[:credit_card])

    respond_to do |format|
      if @credit_card.save
        format.html { redirect_to(@credit_card, :notice => 'Credit card was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end


end
