class Myaccount::OverviewsController < Myaccount::BaseController
  def show

  end

  def edit
    @user = current_user
    form_info
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to myaccount_overview_url(), :notice  => "Successfully updated user."
    else
      form_info
      render :edit
    end
  end

  private
    def form_info

    end

    def selected_myaccount_tab(tab)
      tab == 'profile'
    end
end
