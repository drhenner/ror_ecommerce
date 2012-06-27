class Admin::Generic::DealsController < Admin::Generic::BaseController
  helper_method :sort_column, :sort_direction, :product_types,:deal_types
  def index
    params[:page] ||= 1
    params[:rows] ||= 20
    @deals = Deal.order(sort_column + " " + sort_direction).
                                              paginate(:page => params[:page].to_i, :per_page => params[:rows].to_i)
  end

  def show
    @deal = Deal.find(params[:id])
  end

  def new
    @deal = Deal.new
    form_info
  end

  def create
    @deal = Deal.new(params[:deal])
    if @deal.save
      redirect_to [:admin, :generic, @deal], :notice => "Successfully created deal."
    else
      form_info
      render :new
    end
  end

  def edit
    @deal = Deal.find(params[:id])
    form_info
  end

  def update
    @deal = Deal.find(params[:id])
    if @deal.update_attributes(params[:deal])
      redirect_to [:admin, :generic, @deal], :notice  => "Successfully updated deal."
    else
      form_info
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
    def form_info

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
