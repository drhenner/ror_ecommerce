class Admin::Reports::WeeklyChartsController < Admin::Reports::BaseController
  #helper_method :start_time, :end_time
  before_action :set_time_range
  layout 'admin_charts'
  def index
    @sales_data = RorEReports::Sales.new(start_time, number_of_data_points)
  end

  private

  def set_time_range
    if params[:start_date].present?
      @start_time = Time.parse(params[:start_date])
    else
      Chronic.time_class = Time.zone
      @start_time = Chronic.parse("#{number_of_data_points} weeks ago").beginning_of_week
    end
    set_end_time
  end

  def number_of_data_points
    data_point  = case time_frame
    when 'Daily'
      30
    when 'Weekly'
      13
    when 'Monthly'
      12
    else
      10
    end
  end

  def time_frame
    params[:commit].present? ? params[:commit] : 'Weekly'
  end
end
