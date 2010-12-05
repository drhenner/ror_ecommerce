class Admin::UsersController < Admin::BaseController

  def index
    authorize! :view_users, current_user

    @users = User.admin_grid(params)
  end

  def new
    @user = User.new
    authorize! :create_users, current_user
    form_info
  end

  def create

    @user = User.new(params[:user])
    authorize! :create_users, current_user
    if @user.save
      @user.deliver_activation_instructions!
      redirect_to admin_users_url, :notice => "Your account has been created. Please check your e-mail for your account activation instructions!"
    else
      form_info
      render :action => :new
    end
  end

  def edit
    @user = User.includes(:roles).find(params[:id])
    authorize! :create_users, current_user
    form_info
  end

  def update
    params[:user][:role_ids] ||= []
    @user = User.includes(:roles).find(params[:id])
    authorize! :create_users, current_user
    if @user.update_attributes(params[:user])
      redirect_to admin_users_url, :notice => "#{@user.name} has been updated."
    else
      form_info
      render :action => :edit
    end
  end

  private

  def form_info
    @all_roles = Role.all
  end
end
