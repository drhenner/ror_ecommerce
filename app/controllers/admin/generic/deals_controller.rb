class Admin::Generic::DealsController < Admin::Generic::BaseController
  helper_method :sort_column, :sort_direction, :product_types,:deal_types
  def index
    @deals = Deal.order(sort_column + " " + sort_direction).
                                              paginate(:page => pagination_page, :per_page => pagination_rows)
  end

  def show
    @deal = Deal.find(params[:id])
  end

  def new
    @deal = Deal.new
  end

  def create
    @deal = Deal.new(allowed_params)
    if @deal.save
      redirect_to [:admin, :generic, @deal], :notice => "Successfully created deal."
    else
      render :new
    end
  end

  def edit
    @deal = Deal.find(params[:id])
  end

  def update
    @deal = Deal.find(params[:id])
    if @deal.update_attributes(allowed_params)
      redirect_to [:admin, :generic, @deal], :notice  => "Successfully updated deal."
    else
      render :edit
    end
  end

  def destroy
    @deal = Deal.find(params[:id])
    @deal.deleted_at = Time.zone.now
    @deal.save
    redirect_to admin_generic_deals_url, :notice => "Successfully deleted deal."
  end

  private

    def allowed_params
      params.require(:deal).permit(:buy_quantity, :get_percentage, :deal_type_id, :product_type_id, :get_amount, :deleted_at)
    end

    def product_types
      @select_product_types     ||= ProductType.all.collect{|pt| [pt.name, pt.id]}
    end

    def deal_types
      @select_deal_types     ||= DealType.all.collect{|pt| [pt.name, pt.id]}
    end

    def sort_column
      Deal.column_names.include?(params[:sort]) ? params[:sort] : "buy_quantity"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
