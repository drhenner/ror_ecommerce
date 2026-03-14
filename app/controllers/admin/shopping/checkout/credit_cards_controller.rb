class Admin::Shopping::Checkout::CreditCardsController < Admin::Shopping::Checkout::BaseController
  def index
    @credit_cards = checkout_user.payment_profiles
  end

  def show
    @credit_card = checkout_user.payment_profiles.find(params[:id])
  end

  def new
    @credit_card = checkout_user.payment_profiles.new
  end

  def create
    @credit_card = checkout_user.payment_profiles.new(allowed_params)
    if @credit_card.save
      redirect_to(admin_shopping_checkout_credit_card_path(@credit_card), notice: 'Credit card was successfully created.')
    else
      render action: "new"
    end
  end

  def edit
    @credit_card = checkout_user.payment_profiles.find(params[:id])
  end

  def update
    @credit_card = checkout_user.payment_profiles.find(params[:id])
    if @credit_card.update(allowed_params)
      redirect_to(admin_shopping_checkout_credit_card_path(@credit_card), notice: 'Credit card was successfully updated.')
    else
      render action: "edit"
    end
  end

  def destroy
    @credit_card = checkout_user.payment_profiles.find(params[:id])
    @credit_card.inactivate!
    redirect_to(admin_shopping_checkout_credit_cards_path, notice: 'Credit card was successfully removed.')
  end

  private

  def allowed_params
    params.require(:credit_card).permit(:address_id, :month, :year, :cc_type, :first_name, :last_name, :card_name)
  end
end
