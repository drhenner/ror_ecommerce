class Admin::Fulfillment::CommentsController < Admin::Fulfillment::BaseController
  helper_method :order

  def index
    #@comments = order.comments
    respond_to do |format|
        format.json { render :json => order.comments.to_json, :status => 206}
        format.html { render :action => 'index' }
    end
  end

  def show
    @comment = order.comments.find(params[:id])

    respond_to do |format|
        format.json { render :json => @comment.to_json}
        format.html { render :action => 'show' }
    end
  end

  def new
    form_info
    @comment = order.comments.new
  end

  def create
    @comment              = order.comments.new(params[:comment])
    @comment.created_by   = current_user.id
    @comment.user_id      = order.user_id
    if @comment.save
      flash[:notice] = "Successfully created comment."
      respond_to do |format|
          format.json { render :json => @comment.to_json}
          format.html { render :action => 'show' }
      end
    else
      form_info
      respond_to do |format|
          format.json { render :json => @comment.errors.to_json }
          format.html { render :action => 'new' }
      end
    end
  end

  def edit
    form_info
    @comment = order.comments.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update_attributes(params[:comment])
      flash[:notice] = "Successfully updated comment."
      respond_to do |format|
          format.json { render :json => @comment.to_json}
          format.html { redirect_to admin_fulfillment_order_comment_url(order, @comment) }
      end
    else
      form_info
      respond_to do |format|
          format.json { render :json => @comment.errors.to_json }
          format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @comment = order.comments.find(params[:id])
    @comment.destroy
    flash[:notice] = "Successfully destroyed comment."
    redirect_to admin_fulfillment_order_comments_url(order)
  end

  private

  def form_info

  end

  def order
    return @order if @order
    @order = Order.find_by_number(params[:order_id])
  end
end
