class Admin::Shopping::UsersController < Admin::Shopping::BaseController
  # GET /admin/order/users
  # GET /admin/order/users.xml
  def index
    
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

  # GET /admin/order/users/1
  # GET /admin/order/users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /admin/order/users/new
  # GET /admin/order/users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /admin/order/users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /admin/order/users
  # POST /admin/order/users.xml
  def create
    @user = User.find_by_id(params[:user_id])
    session_admin_cart[:user] = @user
    if @user
      redirect_to(admin_shopping_carts_url, :notice => "#{@user.name} was added.") 
    else
      redirect_to admin_shopping_users_url 
    end
  end

  # PUT /admin/order/users/1
  # PUT /admin/order/users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(admin_shopping_user_url @user, :notice => 'User was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

end
