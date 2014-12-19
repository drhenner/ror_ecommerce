class Admin::Reports::BaseController < Admin::BaseController
  private

  def set_time_range
    if params[:start_date].present?
      @start_time = Time.parse(params[:start_date])
    else
      Chronic.time_class = Time.zone
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
