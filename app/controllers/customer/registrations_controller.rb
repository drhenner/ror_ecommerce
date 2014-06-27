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
    @user = User.new(allowed_params)
    # Saving without session maintenance to skip
    # auto-login which can't happen here because
    # the User has not yet been activated
    if @user.save#_without_session_maintenance
      @user.deliver_activation_instructions!
      @user.active? || @user.activate! if nil # add if you do not require email activation
      @user_session = UserSession.new(:email => params[:user][:email], :password => params[:user][:password])
      @user_session.save
      set_user_to_cart_items(@user)
      cookies[:hadean_uid] = @user.access_token
      session[:authenticated_at] = Time.now
      flash[:notice] = "Your account has been created. Please check your e-mail for your account activation instructions!"
      redirect_back_or_default root_url
    else
      @registration = true
      @user_session = UserSession.new
      render :template => 'user_sessions/new'
    end
  end

  protected

    def allowed_params
      params.require(:user).permit(:password, :password_confirmation, :first_name, :last_name, :email)
    end

end
