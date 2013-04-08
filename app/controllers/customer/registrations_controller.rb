class Customer::RegistrationsController < ApplicationController

  def index
    redirect_to :action => :new
  end

  def new
    @registration = true
    @user         = User.new
    @user_session = UserSession.new
    render :template => 'user_sessions/new'
  end

  def create
    @user = User.new(params[:user])
    @user.format_birth_date(params[:user][:birth_date]) if params[:user][:birth_date].present?
    # Saving without session maintenance to skip
    # auto-login which can't happen here because
    # the User has not yet been activated
    if @user.save_without_session_maintenance
      @user.deliver_activation_instructions!
      #cookies[:hadean_uid] = @user.access_token
      #session[:authenticated_at] = Time.now
      #cookies[:insecure] = false
      UserSession.new(@user.attributes)
      flash[:notice] = "Your account has been created. Please check your e-mail for your account activation instructions!"
      redirect_to root_url
    else
      @registration = true
      @user_session = UserSession.new
      render :template => 'user_sessions/new'
    end
  end

end
