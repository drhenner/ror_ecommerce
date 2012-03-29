class Admin::Rma::ReturnAuthorizationsController < Admin::Rma::BaseController
  helper_method :sort_column, :sort_direction
  # GET /return_authorizations
  def index
    params[:page] ||= 1
    load_info
    @return_authorizations = ReturnAuthorization.admin_grid(params).order(sort_column + " " + sort_direction).
                                              paginate(:per_page => 20, :page => params[:page].to_i)
  end

  # GET /return_authorizations/1
  def show
    load_info
    @return_authorization = ReturnAuthorization.find(params[:id])
  end

  # GET /return_authorizations/new
  def new
    load_info

    @return_authorization = ReturnAuthorization.new
    @return_authorization.comments << (Comment.new(:user_id => @order.user_id, :created_by => current_user.id))
    form_info
  end

  # GET /return_authorizations/1/edit
  def edit
    load_info
    @return_authorization = ReturnAuthorization.includes(:comments).find(params[:id])
    form_info
  end

  # POST /return_authorizations
  def create
    load_info
    @return_authorization = @order.return_authorizations.new(params[:return_authorization])
    @return_authorization.created_by = current_user.id
    @return_authorization.user_id    = @order.user_id

    respond_to do |format|
      if @return_authorization.save
        format.html { redirect_to(admin_rma_order_return_authorization_url(@order, @return_authorization), :notice => 'Return authorization was successfully created.') }
      else
        form_info
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /return_authorizations/1
  def update
    load_info
    @return_authorization = ReturnAuthorization.find(params[:id])

    respond_to do |format|
      if @return_authorization.update_attributes(params[:return_authorization])
        format.html { redirect_to(admin_rma_order_return_authorization_url(@order, @return_authorization), :notice => 'Return authorization was successfully updated.') }
      else
        form_info
        format.html { render :action => "edit" }
      end
    end
  end

  def complete
    load_info
    @return_authorization = ReturnAuthorization.find(params[:id])
    if @return_authorization.complete!
      flash[:notice] = 'This RMA is complete.'
    else
      flash[:error] = 'Something when wrong!'
    end

    render :action => 'show'
  end
  # DELETE /return_authorizations/1
  def destroy
    load_info
    @return_authorization = ReturnAuthorization.find(params[:id])

    respond_to do |format|
      if @return_authorization.cancel!
        format.html { redirect_to(admin_rma_order_return_authorization_url(@order, @return_authorization), :notice => 'Return authorization was successfully updated.') }
      else
        flash[:notice] = 'Return authorization had an error.'
        form_info
        format.html { render :action => "edit" }
      end
    end
  end
private
  def form_info
    @return_conditions  = ReturnCondition.select_form
    @return_reasons     = ReturnReason.select_form
  end

  def load_info
    @order = Order.includes([:ship_address, :invoices,
                             {:shipments => :shipping_method},
                             {:order_items => [
                                                {:variant => [:product, :variant_properties]}]
                              }]).find(params[:order_id])
  end

  def sort_column
    return 'users.last_name' if params[:sort] == 'user_name'
    ReturnAuthorization.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
