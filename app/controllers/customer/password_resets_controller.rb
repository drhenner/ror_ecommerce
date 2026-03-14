class Customer::PasswordResetsController < ApplicationController
  before_action :load_user_using_perishable_token, :only => [ :edit, :update ]

  def new
    @user = User.new
    #render
  end

  def create
    @user = User.find_by_email(params[:user][:email].to_s.strip.downcase)
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = 'Instructions to reset your password have been emailed.'
      render :template => '/customer/password_resets/confirmation'
    else
      @user = User.new
      flash.now[:alert] = 'No user was found with that email address'
      render :action => 'new'
    end
  end

  def edit
    #render
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      #@user.activate!
      flash[:notice] = 'Your password has been reset'
      redirect_to login_url
    else
      render :action => :edit
    end
  end

  protected

  def load_user_using_perishable_token
    unless @user = User.find_by_perishable_token( params[:id].to_s )
      flash[:alert] = 'The link you used is no longer valid. Click the password reset link to get a new link to reset your password.'
      redirect_to login_url and return
    end
  end

end
