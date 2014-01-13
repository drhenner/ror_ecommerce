class Admin::Shopping::CreditCardsController < Admin::Shopping::BaseController
  # GET /admin/order/credit_cards
  def index
    @credit_cards = session_admin_cart[:user].credit_cards
  end

  # GET /admin/order/credit_cards/1
  def show
    @credit_card = session_admin_cart[:user].credit_cards.find(params[:id])
  end

  # GET /admin/order/credit_cards/new
  def new
    @credit_card = CreditCard.new(:user_id => session_admin_cart[:user].id)
  end

  # POST /admin/order/credit_cards
  def create
    @credit_card = session_admin_cart[:user].credit_cards.new(allowed_params)

    respond_to do |format|
      if @credit_card.save
        format.html { redirect_to(@credit_card, :notice => 'Credit card was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end
  private

  def allowed_params
    params.require(:credit_card).permit!
  end
end
