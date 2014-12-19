require 'chronic'

module RorEReports
  class Sales
    def initialize(start_time, number_of_weeks)
      @start_time = start_time
      @number_of_weeks = number_of_weeks
      @end_time   = start_time + number_of_weeks.weeks
      @orders = Order.includes(:completed_invoices).finished.order_by_completion.between(start_time - 1.week, @end_time)
    end

    def weekly_summary
      summary = baseline_report
      @orders.each do |order|
        date = date_for(order.completed_at)
        summary[date.to_s][:amount] += order.first_invoice_amount if date
        summary[date.to_s][:sales]  += 1                          if date
      end
      summary.values
    end

    def date_for(at)
      report_dates.detect{|key, date_string| at.to_date <= key.to_date }.try(:first)
    end

    def report_dates
      @report_dates ||= (@number_of_weeks + 1).times.inject({}) do |h, i|
        h[(@start_time + i.weeks).to_date.to_s] = (@start_time + i.weeks).strftime("%Y-%m-%d")
        h
      end
    end

    def baseline_report
      @baseline_report ||= (@number_of_weeks + 1).times.inject({}) do |h, i|
        h[(@start_time + i.weeks).to_date.to_s] = {
          date:   (@start_time + i.weeks).strftime("%Y-%m-%d"),
          amount: 0,
          sales:  0}
        h
      end
    end
  end
end
