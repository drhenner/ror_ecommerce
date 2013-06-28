class Myaccount::ReferralsController < Myaccount::BaseController
  helper_method :sort_column, :sort_direction
  def index
    @referral  = Referral.new
    @referrals = current_user.referrals.order(sort_column + " " + sort_direction)
  end

  def create
    @referral = current_user.referrals.new(allowed_params)
    @referral.referral_type_id = ReferralType::DIRECT_WEB_FORM_ID
    if @referral.save
      redirect_to myaccount_referrals_url, :notice => "Successfully created referral."
    else
      @referrals = current_user.referrals.order(sort_column + " " + sort_direction)
      render :index
    end
  end

  def update
    @referral = current_user.referrals.find(params[:id])
    if @referral.update_attributes(allowed_params)
      redirect_to myaccount_referrals_url, :notice  => "Successfully updated referral."
    else
      @referrals = current_user.referrals.order(sort_column + " " + sort_direction)
      render :index
    end
  end

  private

    def allowed_params
      params.require(:referral).permit(:email, :name)
    end

    def selected_myaccount_tab(tab)
      tab == 'referrals'
    end

    def sort_column
      Referral.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
