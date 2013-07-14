class Admin::Reports::WeeklyChartsController < Admin::Reports::BaseController
  #helper_method :start_time, :end_time
  before_filter :set_time_range
  layout 'admin_charts'
  def index
    @sales_data = RorEReports::Sales.new(start_time, end_time)
  end

  private

  def set_time_range
    if params[:start_date].present?
      @start_time = Time.parse(params[:start_date])
    else
      @start_time = Chronic.parse('5 weeks ago').beginning_of_week
    end
    set_end_time
  end

  def set_end_time
    @end_time = case time_frame
    when 'Daily'
      start_time + 7.days
    when 'Weekly'
      start_time + 5.weeks
    when 'Monthly'
      start_time + 5.months
    else
      start_time + 5.weeks
    end
  end

  def time_frame
    params[:commit].present? ? params[:commit] : 'Weekly'
  end
end
