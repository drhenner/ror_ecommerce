class Admin::UsersController < Admin::BaseController

  def index
   # @users = User.find( :all)
    authorize! :view_users, current_user

    @users = User.admin_grid(params)
    respond_to do |format|
      format.html
      format.json { render :json => @users.to_jqgrid_json(
        [ :first_name, :last_name, :email, :state ],
        @users.per_page, #params[:page],
        @users.current_page, #params[:rows],
        @users.total_entries)

      }
    end

  end

  def new
    @user = User.new
    authorize! :create_users, current_user
    form_info
  end

  def create

    @user = User.new(params[:user])
    @user.format_birth_date(params[:user][:birth_date]) if params[:user][:birth_date].present?
    authorize! :create_users, current_user
    if @user.save
      @user.deliver_activation_instructions!
      flash[:notice] = "Your account has been created. Please check your e-mail for your account activation instructions!"
      redirect_to admin_users_url
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
    @user.format_birth_date(params[:user][:birth_date]) if params[:user][:birth_date].present?
    @user.state = params[:user][:state]                 if params[:user][:state].present? && !@user.admin?
    params[:user].delete_if {|key, value| key.to_s == "birth_date" }
    if @user.update_attributes(params[:user])
      flash[:notice] = "#{@user.name} has been updated."
      redirect_to admin_users_url
    else
      form_info
      render :action => :edit
    end
  end

  private

  def form_info
    @all_roles = Role.all
    @states    = ['inactive', 'active', 'canceled']
  end
end
