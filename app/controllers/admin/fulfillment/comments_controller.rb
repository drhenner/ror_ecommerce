class Admin::Fulfillment::CommentsController < Admin::Fulfillment::BaseController
  helper_method :order

  def index
    respond_to do |format|
      format.json { render json: order.comments.to_json, status: 206}
      format.html { render action: 'index' }
    end
  end

  def show
    @comment = order.comments.find(params[:id])
    respond_to do |format|
      format.json { render json: @comment.to_json}
      format.html { render action: 'show' }
    end
  end

  def new
    @comment = order.comments.new
  end

  def create
    @comment              = order.comments.new(allowed_params)
    @comment.created_by   = current_user.id
    @comment.user_id      = order.user_id
    respond_to do |format|
      if @comment.save
        flash[:notice] = "Successfully created comment."
        format.json { render json: @comment.to_json}
        format.html { render action: 'show' }
      else
        format.json { render json: @comment.errors.to_json }
        format.html { render action: 'new' }
      end
    end
  end

  def edit
    @comment = order.comments.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    respond_to do |format|
      if @comment.update_attributes(allowed_params)
        flash[:notice] = "Successfully updated comment."
        format.json { render json: @comment.to_json}
        format.html { redirect_to admin_fulfillment_order_comment_url(order, @comment) }
      else
        format.json { render json: @comment.errors.to_json }
        format.html { render action: 'edit' }
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

  def allowed_params
    params.require(:comment).permit(:note)
  end

  def order
    @order ||= Order.find_by_number(params[:order_id])
  end
end
