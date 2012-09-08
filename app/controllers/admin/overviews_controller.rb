class Admin::OverviewsController < ApplicationController

  layout "admin"

  def index
    #  The index action should
    if u = User.first
      redirect_to root_url if !current_user || !current_user.admin?

    elsif Role.first
      ##  This means we don't have any users
      ##  First we need to create a user with all permissions
      @password = "admin_user_#{rand(1000)}"

      @user = User.new(:first_name => 'Admin',
                       :last_name => 'User',
                       :email => 'admin@notarealemail.com',
                       :password => @password,
                       :password_confirmation => @password
                       )
      @user.role_ids = Role.all.collect{|r| r.id }
      if @user.active? || @user.activate!
        @user.save
        @user_session = UserSession.new(:email => @user.email, :password => @password)
        @user_session.save
      end
    else
      ###  If you dont have roles you need to run rake db:seed
      @no_roles = true
    end
  end

end
