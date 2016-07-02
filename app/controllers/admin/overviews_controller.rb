class Admin::OverviewsController < ApplicationController
  helper_method :recent_admin_users
  layout "admin"

  def index
    #  The index action should
    if u = User.first
      redirect_to root_url and return if !current_user
      redirect_to root_url unless current_user.admin?

    elsif Role.first
      ##  This means we don't have any users
      ##  First we need to create a user with all permissions

      @user = User.new(args)
      @user.password = password
      @user.password_confirmation = password
      if @user.active? || @user.activate!
        @user.save
        @user.role_ids = Role.all.map{|r| r.id }
        @user.save
        @current_user = @user
        @user_session = UserSession.new(session_args)
        @user_session.save
      end
    else
      ###  If you dont have roles you need to run rake db:seed
      @no_roles = true
    end
  end
  private
  def session_args
    @session_args ||= { :email => @user.email, :password => @password }
  end

  def args
    @password ||= "admin_user_#{rand(1000)}"
    @args ||= {
    :first_name => 'Admin',
    :last_name => 'User',
    :email => 'admin@notarealemail.com' }
  end

  def password
    @password ||= "admin_user_#{rand(1000)}"
  end

  def recent_admin_users
    []
  end

end
