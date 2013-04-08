class Admin::Shopping::UsersController < Admin::Shopping::BaseController
  helper_method :sort_column, :sort_direction

  # GET /admin/shopping/users
  def index
   params[:page] ||= 1
    @users = User.admin_grid(params).order(sort_column + " " + sort_direction).
                                    paginate(:per_page => 25, :page => params[:page].to_i)
  end

  # POST /admin/shopping/users
  def create
    @customer = User.find_by_id(params[:user_id])
    session_admin_cart.customer = @customer
    add_to_recent_user(@customer)
    if session_admin_cart.save
      redirect_to(admin_shopping_carts_url, :notice => "#{@customer.name} was added.")
    else
      redirect_to admin_shopping_users_url
    end
  end

  private

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "first_name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
