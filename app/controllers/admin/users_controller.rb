class Admin::UsersController < Admin::BaseController
  helper_method :sort_column, :sort_direction

  def index
   # @users = User.find( :all)
    authorize! :view_users, current_user
    params[:page] ||= 1
    # @users = User.admin_grid(params)
    @users = User.admin_grid(params).order(sort_column + " " + sort_direction).
                                    paginate(:per_page => 25, :page => params[:page].to_i)
  end

  def new
    @user = User.new
    authorize! :create_users, current_user
    form_info
  end

  def create
    attribs =  params[:user]
    role_ids    = params[:user][:role_ids]
    state       = params[:user][:state]
    birth_date  = params[:user][:birth_date]

    attribs.delete(:role_ids)
    attribs.delete(:state)
    attribs.delete(:birth_date)

    @user = User.new(params[:user])
    @user.role_ids  = role_ids
    @user.state     = state
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
    @user.role_ids = params[:user][:role_ids]
    @user.format_birth_date(params[:user][:birth_date]) if params[:user][:birth_date].present?
    @user.state = params[:user][:state]                 if params[:user][:state].present? #&& !@user.admin?
    attribs =  params[:user]
    attribs.delete(:role_ids)
    attribs.delete(:state)
    attribs.delete(:birth_date)
    if @user.save && @user.update_attributes(attribs)
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

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "first_name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
