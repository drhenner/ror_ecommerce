class Admin::Reports::OverviewsController < Admin::Reports::BaseController
  helper_method :start_time, :end_time
  before_filter :set_time_range

  def show
    @accounting_report  = RorEReports::Accounting.new(start_time, end_time)
    @orders_report      = RorEReports::Orders.new(start_time, end_time)
    @customers_report   = RorEReports::Customers.new(start_time, end_time)
    @final_number_of_cart_items     = CartItem.before(end_time).last   ? CartItem.before(end_time).last.id   : 0
    @beginning_number_of_cart_items = CartItem.before(start_time).last ? CartItem.before(start_time).last.id : 0
  end

  private

    def set_time_range
      if params[:start_date].present?
        @start_time = Time.parse(params[:start_date])
      else
        @start_time = Chronic.parse('last week').beginning_of_week
      end
      set_end_time
    end

    def set_end_time
      @end_time = case params[:commit]
      when 'Daily'
        start_time + 1.day
      when 'Weekly'
        start_time + 1.week
      when 'Monthly'
        start_time + 1.month
      else
        start_time + 1.week
      end
    end

    def start_time
      @start_time
    end

    def end_time
      @end_time
    end

end
