class Admin::Reports::GraphsController < Admin::Reports::BaseController
  def index
    set_graph_time_range
    sales_data = RorEReports::Sales.new(@graph_start_time, number_of_graph_weeks)
    summary = sales_data.weekly_summary
    @sales_chart_data = {
      labels: summary.map { |d| d[:date] },
      values: summary.map { |d| d[:sales] }
    }
    @earnings_chart_data = {
      labels: summary.map { |d| d[:date] },
      values: summary.map { |d| d[:amount] }
    }
  end

  def show
    #@graphs = Graphs.find(params[:id])
  end

  private

  def set_graph_time_range
    if params[:start_date].present?
      @graph_start_time = Time.parse(params[:start_date])
    else
      Chronic.time_class = Time.zone
      @graph_start_time = Chronic.parse("#{number_of_graph_weeks} weeks ago").beginning_of_week
    end
  end

  def number_of_graph_weeks
    case params[:commit]
    when 'Daily' then 30
    when 'Weekly' then 13
    when 'Monthly' then 12
    else 10
    end
  end
end
